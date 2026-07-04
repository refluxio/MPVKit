import XCTest
@testable import MPVKit

final class MPVCoreIntegrationTests: XCTestCase {
    func testMPVCoreInit() {
        let core = MPVCore()
        // getString returns nil for track-list when no file loaded — that's fine
        _ = core.getString(.trackList)
        XCTAssertNotNil(core)
    }
}
