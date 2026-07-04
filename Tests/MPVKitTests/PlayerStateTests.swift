import XCTest
@testable import MPVKit

final class PlayerStateTests: XCTestCase {

    func testDefaultState() {
        let state = PlayerState()
        XCTAssertFalse(state.isPlaying)
        XCTAssertFalse(state.isBuffering)
        XCTAssertEqual(state.position, .zero)
        XCTAssertEqual(state.duration, .zero)
        XCTAssertEqual(state.volume, 1.0)
        XCTAssertNil(state.error)
    }

    func testPositionFromSeconds() {
        var state = PlayerState()
        state.position = Duration.seconds(95)
        let comps = state.position.components
        XCTAssertEqual(comps.seconds, 95)
    }

    func testVolumeClamp() {
        var state = PlayerState()
        state.volume = 0.5
        XCTAssertEqual(state.volume, 0.5)
    }
}
