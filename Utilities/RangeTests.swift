//
//  RangeTests.swift
//  UtilityTests
//
//  Created by Timothy Wood on 12/5/23.
//

import XCTest

final class RangeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOverlaps() throws {
        XCTAssert((0..<2).overlaps((0..<1)))
        XCTAssert((0..<1).overlaps((0..<2)))
    }

    // Ranges directly next to each other don't overlap
    func testOverlapsNeighbors() throws {
        XCTAssertFalse((0..<2).overlaps((2..<4)))
        XCTAssertFalse((2..<4).overlaps((0..<2)))
    }

    func testOverlapsByOne() throws {
        XCTAssert((0..<3).overlaps((2..<4)))
        XCTAssert((2..<4).overlaps((0..<3)))
    }
}
