// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MPVKit",
    platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17)],
    products: [
        .library(name: "MPVKit", targets: ["MPVKit"]),
    ],
    targets: [
        .target(
            name: "MPVKit",
            dependencies: [
                "Mpv", "Avcodec", "Avfilter", "Avformat", "Avutil",
                "Swresample", "Swscale", "Ass", "Dav1d",
                "Freetype", "Fribidi", "Harfbuzz",
                "Mbedcrypto", "Mbedtls", "Mbedx509",
                "Png16", "Uchardet", "Xml2",
            ],
            path: "Sources/MPVKit",
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("CoreVideo"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("AudioToolbox"),
                .linkedFramework("VideoToolbox"),
                .linkedFramework("Metal"),
                .linkedFramework("CoreAudio"),
                .linkedFramework("Security"),
                .linkedLibrary("bz2"),
                .linkedLibrary("z"),
                .linkedLibrary("iconv"),
            ]
        ),
        .testTarget(
            name: "MPVKitTests",
            dependencies: ["MPVKit"],
            path: "Tests/MPVKitTests"
        ),
        .binaryTarget(name: "Mpv",        path: "libmpv/Mpv.xcframework"),
        .binaryTarget(name: "Avcodec",    path: "libmpv/Avcodec.xcframework"),
        .binaryTarget(name: "Avfilter",   path: "libmpv/Avfilter.xcframework"),
        .binaryTarget(name: "Avformat",   path: "libmpv/Avformat.xcframework"),
        .binaryTarget(name: "Avutil",     path: "libmpv/Avutil.xcframework"),
        .binaryTarget(name: "Swresample", path: "libmpv/Swresample.xcframework"),
        .binaryTarget(name: "Swscale",    path: "libmpv/Swscale.xcframework"),
        .binaryTarget(name: "Ass",        path: "libmpv/Ass.xcframework"),
        .binaryTarget(name: "Dav1d",      path: "libmpv/Dav1d.xcframework"),
        .binaryTarget(name: "Freetype",   path: "libmpv/Freetype.xcframework"),
        .binaryTarget(name: "Fribidi",    path: "libmpv/Fribidi.xcframework"),
        .binaryTarget(name: "Harfbuzz",   path: "libmpv/Harfbuzz.xcframework"),
        .binaryTarget(name: "Mbedcrypto", path: "libmpv/Mbedcrypto.xcframework"),
        .binaryTarget(name: "Mbedtls",    path: "libmpv/Mbedtls.xcframework"),
        .binaryTarget(name: "Mbedx509",   path: "libmpv/Mbedx509.xcframework"),
        .binaryTarget(name: "Png16",      path: "libmpv/Png16.xcframework"),
        .binaryTarget(name: "Uchardet",   path: "libmpv/Uchardet.xcframework"),
        .binaryTarget(name: "Xml2",       path: "libmpv/Xml2.xcframework"),
    ]
)
