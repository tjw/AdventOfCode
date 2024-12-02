//
//  Location.swift
//  day12
//
//  Created by Timothy Wood on 12/11/22.
//

import Foundation

struct Location2D : Hashable {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    init(pair: (Int,Int)) {
        self.x = pair.0
        self.y = pair.1
    }

    func manhattanDistance(to other: Self) -> Int {
        return abs(x - other.x) + abs(y - other.y)
    }

    static func +(left: Self, right: Self) -> Self {
        return Self(x: left.x + right.x, y: left.y + right.y)
    }
    static func -(left: Self, right: Self) -> Self {
        return Self(x: left.x - right.x, y: left.y - right.y)
    }
    static func +=(left: inout Self, right: Self) {
        left = Self(x: left.x + right.x, y: left.y + right.y)
    }

    static prefix func -(value: Self) -> Self {
        return Self(x: -value.x, y: -value.y)
    }

    static let left = Self(x: -1, y: 0)
    static let right = Self(x: 1, y: 0)
    static let up = Self(x: 0, y: 1)
    static let down = Self(x: 0, y: -1)

    static let zero = Self(x: 0, y: 0)

    static let cardinalDirections = [left, right, up, down]
}
