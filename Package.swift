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
        .binaryTarget(name: "Mpv",        url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Mpv.xcframework.zip",        checksum: "12944fa39eb744778f9456739ffed03b58b0032615aa4b7e2089d177c0a3fe19"),
        .binaryTarget(name: "Avcodec",    url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Avcodec.xcframework.zip",    checksum: "9e9be06fb320c16f4f86d89be83c5a2fb4630aed5c3d58b3c0f29df30ba9cfec"),
        .binaryTarget(name: "Avfilter",   url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Avfilter.xcframework.zip",   checksum: "c0d07f12ad06b750e516a3bc9fc9845b3711b2f903ae35a1eb5bd3c24b236968"),
        .binaryTarget(name: "Avformat",   url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Avformat.xcframework.zip",   checksum: "213f300a72d2d2fe0a79bd9ff0d168efe72bd39b0452a9f30d0fbda4edc39755"),
        .binaryTarget(name: "Avutil",     url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Avutil.xcframework.zip",     checksum: "3d77c47a6b88adacac763f06a4cab1f8b442ceb6031f0c76ff31ca893458f158"),
        .binaryTarget(name: "Swresample", url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Swresample.xcframework.zip", checksum: "da4ca8d99501cc95ee2f14095f5cbb13e3ca68bdf44c931e69a26e51c0bf6b87"),
        .binaryTarget(name: "Swscale",    url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Swscale.xcframework.zip",    checksum: "d3b84b2ca1b80c918a0498dedf9f984a662787fe7f561ecbd9bac6c51f667d45"),
        .binaryTarget(name: "Ass",        url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Ass.xcframework.zip",        checksum: "f722f5982a0a4affd277bb50c2137ed6262334c4662274bf87b3df62de4cefcb"),
        .binaryTarget(name: "Dav1d",      url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Dav1d.xcframework.zip",      checksum: "78383bfcf21d432dcde33e1ef46ff6e1bf08c9f22bc48a5e19df2e11b44bbe0d"),
        .binaryTarget(name: "Freetype",   url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Freetype.xcframework.zip",   checksum: "8d06382e8821906bc95b1cbe48809ab6db30fd4ab8af51a42d1b992ee3ec3fa0"),
        .binaryTarget(name: "Fribidi",    url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Fribidi.xcframework.zip",    checksum: "ae540af563b0168437f477c0e98cf0b33f8b3f7763de2703bde2fb6924129637"),
        .binaryTarget(name: "Harfbuzz",   url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Harfbuzz.xcframework.zip",   checksum: "717d09fdd15af853f3642fcfc3c753552a711bf0470a4983f937e138a7092186"),
        .binaryTarget(name: "Mbedcrypto", url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Mbedcrypto.xcframework.zip", checksum: "04dfdab091c822d786aa57e1a8529a1d3a25db67fad91481db8ba5164a34cc18"),
        .binaryTarget(name: "Mbedtls",    url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Mbedtls.xcframework.zip",    checksum: "10e90d1c659474f4f3f2578274b557cac1b47746f1a166b6b5cb8f25972f2303"),
        .binaryTarget(name: "Mbedx509",   url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Mbedx509.xcframework.zip",   checksum: "bb31338b2c4ba5ed3e2650f5c20b00fb54dbc93c22a7396f8137e197bff857ea"),
        .binaryTarget(name: "Png16",      url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Png16.xcframework.zip",      checksum: "1f8ad8150e61c6fe65c849e2fe70c62fc9a9b911f2a346b4d54914fc3e69b162"),
        .binaryTarget(name: "Uchardet",   url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Uchardet.xcframework.zip",   checksum: "06aae7d1709969f919a0c734d7d2cc405c3b101fc1710356e739e32ca2080f7a"),
        .binaryTarget(name: "Xml2",       url: "https://github.com/refluxio/MPVKit/releases/download/v0.1.0/Xml2.xcframework.zip",       checksum: "ada38f156dc2d1c9534f31e853c14b94196d42d7026a056ae7487322d9731645"),
    ]
)
