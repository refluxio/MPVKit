// Packages/MPVKit/Tests/MPVKitTests/VideoColorParamsTests.swift
import XCTest
@testable import MPVKit

final class VideoColorParamsTests: XCTestCase {

    func testDefaultIsSDRBT709Limited() {
        let p = VideoColorParams()
        XCTAssertEqual(p.matrix,   .bt709)
        XCTAssertEqual(p.transfer, .sdr)
        XCTAssertEqual(p.range,    .limited)
    }

    func testBT2020NCLPQLimited() {
        let p = VideoColorParams(mpvColormatrix: "bt.2020-ncl",
                                 mpvGamma: "pq",
                                 mpvColorlevels: "tv")
        XCTAssertEqual(p.matrix,   .bt2020)
        XCTAssertEqual(p.transfer, .pq)
        XCTAssertEqual(p.range,    .limited)
    }

    func testBT2020CLMatrix() {
        let p = VideoColorParams(mpvColormatrix: "bt.2020-cl",
                                 mpvGamma: nil, mpvColorlevels: nil)
        XCTAssertEqual(p.matrix, .bt2020)
    }

    func testBT601Matrix() {
        let p = VideoColorParams(mpvColormatrix: "bt.601",
                                 mpvGamma: nil, mpvColorlevels: nil)
        XCTAssertEqual(p.matrix, .bt601)
    }

    func testHLGTransfer() {
        let p = VideoColorParams(mpvColormatrix: nil,
                                 mpvGamma: "hlg", mpvColorlevels: nil)
        XCTAssertEqual(p.transfer, .hlg)
    }

    func testFullRange() {
        let p = VideoColorParams(mpvColormatrix: nil,
                                 mpvGamma: nil, mpvColorlevels: "pc")
        XCTAssertEqual(p.range, .full)
    }

    func testUnknownValuesFallToDefaults() {
        let p = VideoColorParams(mpvColormatrix: "xyz",
                                 mpvGamma: "xyz", mpvColorlevels: "xyz")
        XCTAssertEqual(p.matrix,   .bt709)
        XCTAssertEqual(p.transfer, .sdr)
        XCTAssertEqual(p.range,    .limited)
    }
}
