import XCTest
@testable import StructuredSlider

final class StructuredSliderTests: XCTestCase {
    func testElementWidth() {
        let steps = Array(repeating: 0, count: 6)
        XCTAssertEqual(steps.elementWidth(in: 323).rounded(), 54)
    }

    func testPosition() {
        let steps = Array(repeating: 0, count: 6)
        XCTAssertEqual(steps.position(for: 2, in: 323).rounded(), 135)
        XCTAssertEqual(steps.position(for: 4, in: 323).rounded(), 242)
    }

    func testIndex() {
        let steps = Array(repeating: 0, count: 6)
        XCTAssertEqual(steps.index(for: 135, in: 323), 2)
        XCTAssertEqual(steps.index(for: 211, in: 323), 3)
        XCTAssertEqual(steps.index(for: 270, in: 323), 5)
        XCTAssertEqual(steps.index(for: -10, in: 323), 0)
        XCTAssertEqual(steps.index(for: 330, in: 323), 5)
        XCTAssertEqual(steps.index(for: 54, in: 323), 1)
        XCTAssertEqual(steps.index(for: 53, in: 323), 0)
    }

    func testThumbOffset() {
        let steps = Array(repeating: 0, count: 6)
        XCTAssertEqual(steps.thumbOffset(for: 0.5, in: 323).rounded(), 135)
        XCTAssertEqual(steps.thumbOffset(for: 0, in: 323).rounded(), 0)
        XCTAssertEqual(steps.thumbOffset(for: 1, in: 323).rounded(), 269)
    }

    func testProgress() {
        let steps = Array(repeating: 0, count: 5)
        XCTAssertEqual(steps.progress(for: 2, in: 323), 0.5)

    }

}
