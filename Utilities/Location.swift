//
//  Location.swift
//  day12
//
//  Created by Timothy Wood on 12/11/22.
//

import Foundation

struct Location : Hashable {
    let x: Int
    let y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    init(pair: (Int,Int)) {
        self.x = pair.0
        self.y = pair.1
    }

    static func +(left: Location, right: Location) -> Location {
        return Location(x: left.x + right.x, y: left.y + right.y)
    }
    static func -(left: Location, right: Location) -> Location {
        return Location(x: left.x - right.x, y: left.y - right.y)
    }
    static func +=(left: inout Location, right: Location) {
        left = Location(x: left.x + right.x, y: left.y + right.y)
    }

    static var left = Location(x: -1, y: 0)
    static var right = Location(x: 1, y: 0)
    static var up = Location(x: 0, y: 1)
    static var down = Location(x: 0, y: -1)

    static var cardinalDirections = [left, right, up, down]
}
