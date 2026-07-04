// Packages/MPVKit/Sources/MPVKit/Render/VideoRenderer.swift
import QuartzCore

// MARK: - VideoColorParams

public struct VideoColorParams: Equatable, Sendable {

    public enum ColorMatrix:  Sendable { case bt709, bt2020, bt601 }
    public enum TransferFunc: Sendable { case sdr, pq, hlg }
    public enum ColorRange:   Sendable { case limited, full }

    public var matrix:   ColorMatrix  = .bt709
    public var transfer: TransferFunc = .sdr
    public var range:    ColorRange   = .limited

    public init() {}

    init(mpvColormatrix: String?, mpvGamma: String?, mpvColorlevels: String?) {
        switch mpvColormatrix {
        case "bt.2020-ncl", "bt.2020-cl": matrix = .bt2020
        case "bt.601":                    matrix = .bt601
        default:                          matrix = .bt709
        }
        switch mpvGamma {
        case "pq":  transfer = .pq
        case "hlg": transfer = .hlg
        default:    transfer = .sdr
        }
        range = mpvColorlevels == "pc" ? .full : .limited
    }
}

// MARK: - RenderPath

public enum RenderPath: Sendable {
    /// OpenGL → CVPixelBuffer → Metal（零拷贝硬解，iOS/tvOS 默认）
    case openglMetal
    /// BGRA → CVMetalTextureCache → CAMetalLayer（支持 EDR / HDR）
    case metal
    /// BGRA → CMSampleBuffer → AVSampleBufferDisplayLayer（兜底）
    case software
}

// MARK: - VideoRenderer

@MainActor
protocol VideoRenderer: AnyObject {
    /// 要加入视图层级的 CALayer（AVSampleBufferDisplayLayer 或 CAMetalLayer）
    var renderLayer: CALayer { get }
    /// 在 CADisplayLink tick 内调用：拉帧并显示
    func renderFrame(width: Int, height: Int)
    /// 清空已显示帧，重置内部状态
    func flush()
    /// 立即在 layer 上显示黑帧（不依赖 display link）
    func clear()
    /// 更新色彩空间参数（MetalRenderer 用于切换 shader uniform 和 layer colorspace）
    func updateColorParams(_ params: VideoColorParams)
}
