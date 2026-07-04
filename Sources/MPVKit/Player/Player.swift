import AVFoundation
import Foundation

// MARK: - Player

@Observable
@MainActor
public final class Player {

    // MARK: Public state
    public var state = PlayerState()

    // MARK: Internal components
    let core: MPVCore
    private var swRenderCtx: MPVRenderContext?
    #if os(iOS) || os(tvOS)
    private var glRenderCtx: OpenGLRenderContext?
    #endif
    let bridge:   DisplayBridge

    @ObservationIgnored private nonisolated(unsafe) var eventTask: Task<Void, Never>?

    // MARK: Init

    public init() throws {
        core = MPVCore()
        let initialRenderer: VideoRenderer

        #if os(iOS) || os(tvOS)
        #if !targetEnvironment(simulator)
        // 首选 OpenGL + Metal（零拷贝 VideoToolbox 硬解）
        if let glCtx = try? OpenGLRenderContext(core: core),
           let mr = try? GLMetalRenderer(renderCtx: glCtx) {
            glRenderCtx = glCtx
            bridge = DisplayBridge(renderer: mr)
            startEventLoop()
            return
        }
        NSLog("[mpvkit] OpenGL+Metal unavailable, falling back to SW+Metal")
        #endif
        #endif

        // SW + Metal 或 SW + AVSampleBufferDisplayLayer
        let ctx = try MPVRenderContext(core: core)
        swRenderCtx = ctx
        if let mr = try? MetalRenderer(renderCtx: ctx) {
            initialRenderer = mr
        } else {
            initialRenderer = SWRenderer(renderCtx: ctx)
        }
        bridge = DisplayBridge(renderer: initialRenderer)
        startEventLoop()
    }

    // MARK: - Playback API

    public func play(url: URL, headers: [String: String] = [:]) {
        if !headers.isEmpty { core.setHTTPHeaders(headers) }
        core.command(["loadfile", url.absoluteString])
        bridge.flush()
        bridge.clear()
        bridge.start()
        state.isBuffering = true
    }

    public func pause() {
        core.setFlag(.pause, true)
    }

    public func resume() {
        core.setFlag(.pause, false)
    }

    /// 播放器界面消失时调用：暂停 + flush + 清屏 + 停止渲染循环。
    /// 下次 play() 时会重建 displayLink，确保干净的状态。
    public func prepareForReuse() {
        core.setFlag(.pause, true)
        bridge.flush()
        bridge.clear()
        bridge.stop()
    }

    public func seek(to position: Duration) {
        let comps = position.components
        let secs = Double(comps.seconds) + Double(comps.attoseconds) * 1e-18
        core.command(["seek", String(format: "%.3f", secs), "absolute"])
    }

    public func setVolume(_ volume: Double) {
        let clamped = max(0, min(1, volume))
        state.volume = clamped
        core.setDouble(.volume, clamped * 100)
    }

    public func selectAudioTrack(id: String) {
        core.setString(.aid, id)
    }

    public func selectSubtitle(id: String?) {
        core.setString(.sid, id ?? "no")
    }

    public func setRate(_ rate: Double) {
        let clamped = max(0.25, min(4.0, rate))
        state.rate = clamped
        core.setDouble(.speed, clamped)
    }

    /// 运行时切换硬解（true = videotoolbox，false = 纯软解）。
    /// 对当前播放立即生效，下一帧起切换。
    public func setHwAccel(_ enabled: Bool) {
        core.setString(.hwdec, enabled ? "videotoolbox" : "no")
    }

    /// 运行时切换渲染后端（仅 SW 路径可切换）。
    /// - openglMetal：需在 init 时选择，运行时无法从 SW 切换
    /// - metal：BGRA → CVMetalTextureCache → CAMetalLayer EDR
    /// - software：BGRA → CMSampleBuffer → AVSampleBufferDisplayLayer（兜底）
    public func setRenderPath(_ path: RenderPath) {
        switch path {
        case .openglMetal:
            break
        case .metal:
            guard let ctx = swRenderCtx else { return }
            if let mr = try? MetalRenderer(renderCtx: ctx) {
                bridge.setRenderer(mr)
            }
        case .software:
            guard let ctx = swRenderCtx else { return }
            bridge.setRenderer(SWRenderer(renderCtx: ctx))
        }
    }

    public func stop() {
        core.command(["stop"])
        bridge.stop()
        bridge.flush()
        state = PlayerState()
    }

    /// 暂停/恢复渲染循环（方向切换时调用）
    public func pauseRender() { bridge.pause() }
    public func resumeRender() { bridge.resume() }

    // MARK: - Event loop

    private func startEventLoop() {
        let stream = core.events
        eventTask = Task { [weak self] in
            for await event in stream {
                await MainActor.run { [weak self] in self?.handle(event) }
            }
        }
    }

    private func handle(_ event: MPVEvent) {
        switch event {
        case .fileLoaded:
            core.setFlag(.pause, false)
            state.duration    = Duration.seconds(core.getDouble(.duration))
            state.isBuffering = false
            state.isPlaying   = true
            let w = Int(core.getInt64(.width))
            let h = Int(core.getInt64(.height))
            if w > 0 { bridge.videoWidth  = w }
            if h > 0 { bridge.videoHeight = h }
            refreshTracks()
            refreshVideoInfo()
        case .startFile:
            state.isBuffering = true
            bridge.flush()
        case .endOfFile(let reason):
            if reason == .eof || reason == .stop {
                state.isPlaying = false
            }
        case .propertyChange(let name, let value):
            handlePropertyChange(name: name, value: value)
        case .videoReconfig:
            let w = Int(core.getInt64(.width))
            let h = Int(core.getInt64(.height))
            bridge.videoWidth  = w
            bridge.videoHeight = h
            let params = VideoColorParams(
                mpvColormatrix: core.getString(.videoParamsColormatrix),
                mpvGamma:       core.getString(.videoParamsGamma),
                mpvColorlevels: core.getString(.videoParamsColorlevels))
            bridge.updateColorParams(params)
            refreshVideoInfo()
        case .shutdown, .unknown, .audioReconfig, .playbackRestart:
            break
        }
    }

    private func handlePropertyChange(name: MPVPropertyName, value: MPVValue) {
        switch name {
        case .timePos:
            if case .double(let secs) = value {
                state.position = Duration.seconds(secs)
            }
        case .duration:
            if case .double(let secs) = value {
                state.duration = Duration.seconds(secs)
            }
        case .pause:
            if case .bool(let paused) = value {
                state.isPlaying = !paused
            }
        case .cacheBufferingState:
            if case .int64(let pct) = value {
                state.isBuffering = pct < 100
            }
        case .demuxerCacheDuration:
            if case .double(let secs) = value, secs > 0 {
                state.bufferedDuration = state.position + Duration.seconds(secs)
            } else {
                state.bufferedDuration = .zero
            }
        case .cacheSpeed:
            if case .int64(let bps) = value {
                state.cacheSpeed = bps
            }
        case .width:
            if case .int64(let w) = value, w > 0 {
                bridge.videoWidth = Int(w)
            }
        case .height:
            if case .int64(let h) = value, h > 0 {
                bridge.videoHeight = Int(h)
            }
        case .speed:
            if case .double(let s) = value {
                state.rate = s
            }
        default:
            break
        }
    }

    deinit {
        eventTask?.cancel()
    }

    // MARK: - Track & video info refresh

    private func refreshTracks() {
        guard let json = core.getJSON("track-list"),
              let data = json.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return }

        var audio: [TrackInfo] = []
        var subs: [TrackInfo] = []

        for item in array {
            guard let id = item["id"] as? Int,
                  let type = item["type"] as? String else { continue }
            let track = TrackInfo(
                id: id,
                title: item["title"] as? String ?? item["codec"] as? String,
                lang: item["lang"] as? String,
                codec: item["codec"] as? String,
                isDefault: item["default"] as? Bool ?? false
            )
            switch type {
            case "audio":    audio.append(track)
            case "sub":      subs.append(track)
            default: break
            }
        }
        state.audioTracks = audio
        state.subtitleTracks = subs
    }

    private func refreshVideoInfo() {
        let w = Int(core.getInt64(.width))
        let h = Int(core.getInt64(.height))
        guard w > 0, h > 0 else { return }
        let gamma = core.getString(.videoParamsGamma) ?? ""
        state.videoInfo = VideoInfo(
            width: w,
            height: h,
            codec: core.getString(.videoParamsCodec),
            isHDR: gamma == "pq" || gamma == "hlg",
            colorMatrix: core.getString(.videoParamsColormatrix),
            transfer: gamma.isEmpty ? nil : gamma
        )
    }
}
