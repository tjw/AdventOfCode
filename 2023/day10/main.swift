//
//  main.swift
//  day10
//
//  Created by Timothy Wood on 12/9/23.
//

import Foundation

let lines = Input.lines()

extension Location2D {
    static let north = Self.down
    static let south = Self.up
    static let east = Self.right
    static let west = Self.left
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

print("start \(start!)")

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
//    print("move to location \(location) by moving in direction \(direction)")

    let pipe = map[location]!!
//    print("  pipe \(pipe.rawValue)")

    direction = pipe.directionToLeaveFrom(direction)
//    print("  direction now \(direction)")
//    print("  step: \(steps)")
}

print("\(steps/2)")
assert(steps/2 == 6867)

@MainActor
func printMap(showPath: Bool = true) {
    print("~~~~~~~~")
    map.forEachRow { y, row in
        var line = ""
        for x in 0..<row.count {
            let location = Location2D(x: x, y: y)
            guard let pipe = row[x] else {
                assert(!loop.contains(location))
                line.append(".")
                continue
            }
            if showPath && loop.contains(location) {
                line.append("*")
            } else {
                line.append(pipe.rawValue)
            }
        }

        print("\(line)")
    }
}
printMap()

// Contained spans have a 'vertical' pipe on either side of them with the even-odd rule.
// First, convert disconnected pipes into plain land (nils)

map.forEach { location, pipe in
    if !loop.contains(location) {
        let plain: Pipe? = nil
        map[location] = plain
    }
}
printMap(showPath: false)



// Scan across each row, counting transistions between three states, outside, edge, and inside. Edge is for horizontal edges.
// For example, | will toggle between inside and outside directly, but F will go to edge (but needs to remember whether the previous corner.

/*
  For example with:

    IF--------7x

 the 'x' should also be I if it is plain land since we have an edge briefly intruding into the inside area.

 But with:

    IF--------Jx

 'x' should O since we have a line cutting off the inside portion

 */

enum InsideState {
    case outside
    case inside
    case edge(Pipe, Bool) // The corner pipe that started this horizontal edge and whether we were inside before

    var isEdge: Bool {
        switch self {
        case .outside, .inside:
            return false
        case .edge(_, _):
            return true
        }
    }

    var isInside: Bool {
        switch self {
        case .outside:
            return false
        case .inside:
            return true
        case .edge(_, _):
            return false
        }
    }

    var flippedInside: InsideState {
        switch self {
        case .outside, .inside:
            fatalError()
        case .edge(_, let wasInside):
            return wasInside ? .outside : .inside
        }
    }

    var originalInside: InsideState {
        switch self {
        case .edge(_, let wasInside):
            return wasInside ? .inside : .outside
        default:
            fatalError()
        }
    }

    var previousCorner: Pipe {
        switch self {
        case .edge(let pipe, _):
            return pipe
        default:
            fatalError()
        }
    }
}

print("~~~~~~~~")
var insideCount = 0
map.forEachRow { _, _pipes in
    var insideState = InsideState.outside
    var line = ""

    var pipes = _pipes[...]

    while !pipes.isEmpty {
        // Plain land? If we are inside, bump the count
        guard let pipe = pipes.first! else {
            switch insideState {
            case .inside:
                insideCount += 1
                line.append("I")
            case .outside:
                line.append("O")
            case .edge(_, _):
                fatalError()
            }
            pipes = pipes.dropFirst()
            continue
        }

        pipes = pipes.dropFirst()
        line.append(pipe.rawValue)

        switch pipe {
        case .EW:
            // '-' should only be the case when we already have a corner that started an edge
            assert(insideState.isEdge)
            // Horizontal pipe path isn't inside
            break
        case .NS:
            assert(insideState.isEdge == false)
            insideState = insideState.isInside ? .outside : .inside

        case .NE, .SE:
            // "F" or "L", transitioning to an edge
            insideState = .edge(pipe, insideState.isInside)

        case .NW:
            // "J", transitioning away from an edge
            assert(insideState.isEdge)
            assert(insideState.previousCorner == .NE || insideState.previousCorner == .SE)
            if insideState.previousCorner == .SE {
                insideState = insideState.flippedInside
            } else {
                insideState = insideState.originalInside
            }
        case .SW:
            // "7", transitioning away from an edge
            assert(insideState.isEdge)
            assert(insideState.previousCorner == .NE || insideState.previousCorner == .SE)
            if insideState.previousCorner == .NE {
                insideState = insideState.flippedInside
            } else {
                insideState = insideState.originalInside
            }
        }
    }

    print("\(line)")
}
print("\(insideCount)")
assert(insideCount == 595)
