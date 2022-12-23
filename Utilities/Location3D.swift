//
//  Location3D.swift
//  day18
//
//  Created by Timothy Wood on 12/22/22.
//

import Foundation

struct Location3D : Hashable {
    var x: Int
    var y: Int
    var z: Int

    init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    func manhattanDistance(to other: Self) -> Int {
        return abs(x - other.x) + abs(y - other.y) + abs(z - other.z)
    }

    static func +(left: Self, right: Self) -> Self {
        return Self(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
    }
    static func -(left: Self, right: Self) -> Self {
        return Self(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
    }
    static func +=(left: inout Self, right: Self) {
        left = Self(x: left.x + right.x, y: left.y + right.y, z: left.z - right.z)
    }

    static var left = Self(x: -1, y: 0, z: 0)
    static var right = Self(x: 1, y: 0, z: 0)
    static var up = Self(x: 0, y: 1, z: 0)
    static var down = Self(x: 0, y: -1, z: 0)
    static var forward = Self(x: 0, y: 0, z: 1)
    static var backward = Self(x: 0, y: 0, z: -1)

    static var cardinalDirections = [left, right, up, down, forward, backward]
}
