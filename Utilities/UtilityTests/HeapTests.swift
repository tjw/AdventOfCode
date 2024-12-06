//
//  HeapTests.swift
//  AdventOfCode-2015
//
//  Created by Timothy Wood on 12/5/24.
//

import XCTest

final class HeapTests: XCTestCase {

    func test1() throws {
        var heap = Heap<Int>(elements: [], isBefore: <)
        XCTAssert(heap.isEmpty)

        heap.insert(1)
        XCTAssertFalse(heap.isEmpty)

        let result = heap.removeFirst()
        XCTAssertEqual(result, 1)
        XCTAssert(heap.isEmpty)
    }

    func test2() throws {
        var heap = Heap<Int>(elements: [3, 2, 5, 6, 8, 7, 1, 0, 9, 4], isBefore: <)

        var output = [Int]()
        while !heap.isEmpty {
            output.append(heap.removeFirst())
        }
        XCTAssertEqual(output, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    }
}

