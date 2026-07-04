# MPVKit

A Swift-native media player framework for Apple platforms, powered by [libmpv](https://mpv.io).

MPVKit wraps libmpv's C API into a modern Swift interface with `@Observable` state, `AsyncStream`-driven events, and multiple rendering pipelines — including Metal EDR for HDR and OpenGL zero-copy VideoToolbox decoding.

Built by the [reflux](https://github.com/refluxio) team.

## Features

- **Swift-native API** — `@Observable` PlayerState, `AsyncStream<MPVEvent>`, no delegates
- **3 rendering pipelines** — SW → AVSampleBufferDisplayLayer (fallback), SW → Metal EDR (HDR), OpenGL → Metal (zero-copy VideoToolbox on iOS/tvOS)
- **HDR / EDR** — HDR10, HLG, Dolby Vision via CAMetalLayer + CAEDRMetadata
- **Hardware decoding** — VideoToolbox with automatic fallback to software
- **Runtime renderer switching** — change render path without re-creating the player
- **SwiftUI integration** — `PlayerView` drops directly into your view hierarchy
- **Cross-platform** — iOS 17+, macOS 14+, tvOS 17+

## Requirements

- Xcode 16+
- Swift 5.9+
- macOS 14.0+ / iOS 17.0+ / tvOS 17.0+

## Installation

### 1. Add the package

In Xcode: **File → Add Package Dependencies → Add Local** or paste the repository URL.

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/refluxio/MPVKit", from: "0.1.0"),
],
targets: [
    .target(name: "YourApp", dependencies: ["MPVKit"]),
]
```

### 2. Link to your target

In your Xcode project, select your target → **General → Frameworks, Libraries, and Embedded Content** → add `MPVKit`.

SPM resolves and downloads the pre-built libmpv + FFmpeg xcframeworks (LGPL 2.1+) automatically — no manual download step needed.

## Quick Start

```swift
import SwiftUI
import MPVKit

struct ContentView: View {
    @State private var player: Player

    init() {
        do {
            _player = State(wrappedValue: try Player())
        } catch {
            fatalError("Player init failed: \(error)")
        }
    }

    var body: some View {
        VStack {
            PlayerView(player: player)

            // Playback controls
            HStack {
                Button("Play") { player.play(url: URL(string: "https://example.com/video.mkv")!) }
                Button("Pause") { player.pause() }
                Button("Resume") { player.resume() }
            }

            // State observation (automatic via @Observable)
            Text("\(formatDuration(player.state.position)) / \(formatDuration(player.state.duration))")
        }
    }
}
```

## API Overview

### Player

The central controller. Create once, reuse across views.

```swift
let player = try Player()

// Playback
player.play(url: url, headers: ["Authorization": "Bearer xxx"])
player.pause()
player.resume()
player.seek(to: .seconds(30))
player.stop()

// Tracks
player.selectAudioTrack(id: "2")
player.selectSubtitle(id: "1")
player.setVolume(0.8)
player.setRate(1.5)
player.setHwAccel(true)       // VideoToolbox on/off
player.setRenderPath(.metal)   // Switch renderer at runtime

// Lifecycle
player.prepareForReuse()  // Stop rendering, ready for next video
```

### PlayerState

Observable state, automatically updates SwiftUI views.

```swift
@Observable
public struct PlayerState {
    public var isPlaying: Bool
    public var isBuffering: Bool
    public var position: Duration
    public var duration: Duration
    public var volume: Double          // 0...1
    public var rate: Double            // 0.25...4.0
    public var bufferedDuration: Duration
    public var cacheSpeed: Int64       // bytes/sec
    public var audioTracks: [TrackInfo]
    public var subtitleTracks: [TrackInfo]
    public var videoInfo: VideoInfo?
    public var error: String?
}
```

### Events

```swift
// AsyncStream of all mpv events
let stream = player.core.events
for await event in stream {
    switch event {
    case .fileLoaded:      // Video ready to play
    case .endOfFile:       // Playback finished
    case .videoReconfig:   // Resolution/color change
    case .propertyChange:  // Any observed property changed
    default: break
    }
}
```

### Rendering Pipelines

| Pipeline | Platforms | Path | Use Case |
|----------|-----------|------|----------|
| **OpenGL → Metal** | iOS, tvOS | mpv GL render → CVPixelBuffer → Metal display | Zero-copy VideoToolbox, best quality |
| **SW → Metal** | All | mpv SW render → CVPixelBuffer → Metal EDR | HDR/EDR, Catmull-Rom upscaling |
| **SW → ASBDL** | All | mpv SW render → CMSampleBuffer → AVSampleBufferDisplayLayer | Fallback, no Metal needed |

Automatic selection: iOS/tvOS tries OpenGL → Metal first, falls back to SW → Metal → SW → ASBDL. macOS uses SW → Metal by default.

Switch at runtime:

```swift
player.setRenderPath(.metal)     // BGRA → Metal EDR
player.setRenderPath(.software)  // BGRA → AVSampleBufferDisplayLayer
```

## Architecture

```
┌─────────────┐
│   SwiftUI    │  PlayerView / PlayerNativeView
├─────────────┤
│    Player    │  @Observable, playback API, event handling
├─────────────┤
│ DisplayBridge│  CADisplayLink render loop, renderer switching
├──────┬──────┤
│  SW  │  GL  │  VideoRenderer protocol implementations
│Renderer│Renderer│
├──────┴──────┤
│MPVRenderCtx │  mpv_render_context lifecycle, frame callbacks
├─────────────┤
│   MPVCore   │  libmpv C API wrapper, commands, properties
├─────────────┤
│ MPVEventLoop│  Dedicated thread, AsyncStream<MPVEvent>
├─────────────┤
│   libmpv    │  C library (demux, decode, A/V sync, subtitle)
└─────────────┘
```

## License

MPVKit is available under the **GNU General Public License v3.0**.

- **Open-source projects**: Free to use under GPL 3.0 (your project must also be open-source)
- **Closed-source / commercial use**: A separate commercial license is available — contact us at reflux

The bundled libmpv and FFmpeg xcframeworks are licensed under **LGPL 2.1+** and are not covered by the GPL 3.0 license. See [LICENSE](LICENSE) for details.

## Credits

- [libmpv](https://mpv.io) — the core player engine
- [FFmpeg](https://ffmpeg.org) — multimedia framework
- [media-kit/libmpv-darwin-build](https://github.com/media-kit/libmpv-darwin-build) — pre-built xcframeworks for Apple platforms
