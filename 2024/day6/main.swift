//
//  main.swift
//  day6
//
//  Created by Timothy Wood on 12/5/24.
//

import Foundation

enum MapElement: String {
    case empty = "."
    case obstacle = "#"
}

var initialLocation = Location2D(x: -1, y: -1)
var initialDirection = Location2D.zero

// Reverse lines to not havw the map flipped
let map = GridMap<MapElement>(lines: Input.lines().reversed()) { loc, ch in
    switch ch {
    case ".":
        return .empty
    case "#":
        return .obstacle
    case "^":
        initialLocation = loc
        initialDirection = .up
        return .empty
    default:
        fatalError()
    }
}

func turnRight(from direction: Location2D) -> Location2D {
    switch direction {
    case .left:
        return .up
    case .up:
        return .right
    case .right:
        return .down
    case .down:
        return .left
    default:
        fatalError()
    }
}

do {
    var location = initialLocation
    var direction = initialDirection
    var visited = Set<Location2D>([location])

    while true {
        let candidate = location + direction
        if !map.contains(location: candidate) {
            // Walked off the map
            break
        }

        if map[candidate] == .obstacle {
            direction = turnRight(from: direction)
        } else {
            location = candidate
            visited.insert(candidate)
        }
    }

    let result = visited.count
    print("\(result)")
    assert(result == 4778)
}

do {
    var count = 0

    map.forEach { loc, element in
        if loc == initialLocation {
            return
        } else if map[loc] == .obstacle {
            return
        }

        print("trying \(loc)")

        // Temporary new obstacle
        map[loc] = .obstacle

        // Walk the route to see if there is a loop
        var location = initialLocation
        var direction = initialDirection

        // Has to match *both* the position and direction to surely be a loop
        struct State : Hashable {
            let location: Location2D
            let direction: Location2D
        }
        var visited = Set<State>([State(location: location, direction: direction)])

        while true {
            let candidate = location + direction
            if !map.contains(location: candidate) {
                // Walked off the map, no loop
                break
            }

            if map[candidate] == .obstacle {
                direction = turnRight(from: direction)
            } else {
                location = candidate
            }

            let state = State(location: location, direction: direction)
            if visited.contains(state) {
                count += 1
                break
            }
            visited.insert(state)
        }

        // Remove temporary obstacle
        map[loc] = .empty
    }

    print("\(count)")
    assert(count == 1618)
}
