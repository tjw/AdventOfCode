//
//  main.swift
//  day10
//
//  Created by Timothy Wood on 12/9/23.
//

import Foundation

let lines = Input.lines()

extension Location2D {
    static var north = Self.down
    static var south = Self.up
    static var east = Self.right
    static var west = Self.left
}

enum Pipe : Character, RawRepresentable {
    case NS = "|"
    case EW = "-"
    case NE = "L"
    case NW = "J"
    case SW = "7"
    case SE = "F"

    var directions: [Location2D] {
        switch self {
        case .NS:
            return [.north, .south]
        case .EW:
            return [.east, .west]
        case .NE:
            return [.north, .east]
        case .NW:
            return [.north, .west]
        case .SW:
            return [.south, .west]
        case .SE:
            return [.south, .east]
        }
    }

    // When entering from the given location, return the other connected direction
    func directionToLeaveFrom(_ direction: Location2D) -> Location2D {
        let directions = self.directions
        assert(directions.contains(-direction))

        return directions.first == -direction ? directions[1] : directions[0]
    }
}

var start: Location2D! = nil
let map = GridMap<Pipe?>(lines: lines) { location, ch in
    if let pipe = Pipe(rawValue: ch) { return pipe }
    if ch == "." {
        return nil
    }
    if ch == "S" {
        start = location
        return .NE // TODO: Should infer this from the map, but basing this on just looking at the actual input
    }
    fatalError("Unknown map character")
}

print("start \(start)")

var steps = 0
var location = start!
var direction = map[location]!!.directions.first! // Can go either way
print("start: \(location), direction: \(direction)")

var loop = Set<Location2D>()
while true {
    if loop.contains(location) {
        break
    }

    loop.insert(location)

    location = location + direction
    steps += 1
    print("move to location \(location) by moving in direction \(direction)")

    let pipe = map[location]!!
    print("  pipe \(pipe.rawValue)")

    direction = pipe.directionToLeaveFrom(direction)
    print("  direction now \(direction)")
    print("  step: \(steps)")
}
