import XCTest
@testable import MPVKit

final class MPVPropertyTests: XCTestCase {

    func testPropertyRawValues() {
        XCTAssertEqual(MPVPropertyName.timePos.rawValue,             "time-pos")
        XCTAssertEqual(MPVPropertyName.duration.rawValue,            "duration")
        XCTAssertEqual(MPVPropertyName.pause.rawValue,               "pause")
        XCTAssertEqual(MPVPropertyName.volume.rawValue,              "volume")
        XCTAssertEqual(MPVPropertyName.aid.rawValue,                 "aid")
        XCTAssertEqual(MPVPropertyName.sid.rawValue,                 "sid")
        XCTAssertEqual(MPVPropertyName.cacheBufferingState.rawValue, "cache-buffering-state")
        XCTAssertEqual(MPVPropertyName.width.rawValue,               "width")
        XCTAssertEqual(MPVPropertyName.height.rawValue,              "height")
    }

    func testMPVEventEndReasonMapping() {
        XCTAssertEqual(MPVEvent.EndReason.eof.rawValue,      0)
        XCTAssertEqual(MPVEvent.EndReason.stop.rawValue,     2)
        XCTAssertEqual(MPVEvent.EndReason.quit.rawValue,     3)
        XCTAssertEqual(MPVEvent.EndReason.error.rawValue,    4)
        XCTAssertEqual(MPVEvent.EndReason.redirect.rawValue, 5)
    }
}
