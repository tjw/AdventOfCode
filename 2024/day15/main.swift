//
//  main.swift
//  day15
//
//  Created by Timothy Wood on 12/14/24.
//

import Foundation

do {
    enum MapLocation : Character, GridCharacter {

        case wall = "#"
        case box = "O"
        case empty = "."

        var character: Character {
            rawValue
        }
    }

    let sections = Input.sections()
    var location: Location2D = .zero
    let map = GridMap<MapLocation>(lines: sections[0]) { loc, ch in
        if ch == "@" {
            location = loc
            return .empty
        }
        return MapLocation(rawValue: ch)!
    }

    func printMap() {
        print("Map:")

        for y in 0..<map.height {
            let row = map.row(y: y)
            for x in 0..<map.width {
                if location.x == x && location.y == y {
                    print("@", terminator: "")
                } else {
                    print(map[Location2D(x: x, y: y)]!.character, terminator: "")
                }
            }
            print("")
        }
        print("\n")
    }

    //printMap()

    let moves = sections[1].joined()

    // We implicitly assume the map is surrounded by walls instead of checking for going off the map

    moves.forEach { move in
        let dir: Location2D =
        switch move {
        case "<":
                .left
        case ">":
                .right

            // They have 0,0 at the top left
        case "^":
                .down
        case "v":
                .up
        default:
            fatalError()
        }

        func doMove() {
            let candidate = location + dir

            switch map[candidate]! {
            case .empty:
                // Just move
                location = candidate
            case .wall:
                // Nothing happens
                return
            case .box:
                // Continue looking in this direction until we find an empty or wall
                var next = candidate
                while true {
                    next = next + dir
                    switch map[next]! {
                    case .wall:
                        // Blocked
                        return
                    case .empty:
                        // Can "move" this sequence of boxes with just two updates
                        map[candidate] = .empty
                        map[next] = .box
                        location = candidate
                        return
                    case .box:
                        // Keep going, pushing a bigger stack
                        break
                    }
                }
            }
        }
        doMove()

        //    printMap()
    }

    var total = 0
    map.forEach { loc, element in
        if element == .box {
            total += loc.y * 100 + loc.x
        }
    }
    print("\(total)")
}
