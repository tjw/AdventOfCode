//
//  main.swift
//  day15
//
//  Created by Timothy Wood on 12/14/24.
//

import Foundation

/*
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
*/

enum MapLocation : Character, GridCharacter {

    case wall = "#"
    case boxLeft = "["
    case boxRight = "]"
    case empty = "."

    var character: Character {
        rawValue
    }
}

// Read the map again, performing the doubling up operation
let sections = Input.sections()
var location: Location2D = .zero

let mapLines = sections[0].map { line in
    line.compactMap { ch in
        switch ch {
        case "@":
            return "@."
        case "#":
            return "##"
        case "O":
            return "[]"
        case ".":
            return ".."
        default:
            fatalError()
        }
    }.joined()
}
let map = GridMap<MapLocation>(lines: mapLines) { loc, ch in
    if ch == "@" {
        location = loc
        return .empty
    }
    return MapLocation(rawValue: ch)!
}

func printMap() {
    print("Map:")

    for y in 0..<map.height {
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
printMap()

let moves = sections[1].joined()

// We implicitly assume the map is surrounded by walls instead of checking for going off the map

func doHorizontalMove(_ dir: Location2D) -> Bool {
    let candidate = location + dir
    //print("location \(location)")
    //print("dir \(dir)")
    //print("candidate \(candidate)")
    //print("map width \(map.width), height \(map.height)")
    var element = map[candidate]!
    if element == .empty {
        location = candidate
        return true
    }
    if element == .wall {
        return false
    }

    // Depending on whether we are moving left or right, we should first see a '[' or ']' and then the other
    let boxEdges: [MapLocation]
    if dir == .left {
        boxEdges = [.boxRight, .boxLeft]
    } else if dir == .right {
        boxEdges = [.boxLeft, .boxRight]
    } else {
        fatalError("Unexpected map element")
    }

    // Look for an alternating sequence of box edges
    var boxEdge = 0
    assert(element == boxEdges[0])

    while true {
        let next = map[candidate + dir * boxEdge]
        if next == boxEdges[0] {
            assert(map[candidate + dir * (boxEdge + 1)] == boxEdges[1]) // No mismatched boxes!
            boxEdge += 2
            continue
        }
        if next == .wall {
            return false
        }
        if next == .empty {
            // Move all the boxes one step
            while boxEdge > 0 {
                map[candidate + dir * boxEdge] = map[candidate + dir * (boxEdge - 1)]
                boxEdge -= 1
                //printMap()
            }
            map[candidate] = .empty
            location = candidate
            return true
        }
    }
}

func doVerticalMove(_ dir: Location2D) -> Bool {
    let candidate = location + dir
//    print("location \(location)")
//    print("dir \(dir)")
//    print("candidate \(candidate)")
//    print("map width \(map.width), height \(map.height)")
    var element = map[candidate]!
    if element == .empty {
        location = candidate
        return true
    }
    if element == .wall {
        return false
    }

    // The element should be a left/right box edge. Keep track of a set of locations for each row that is being pushed. This first box might push another box, etc. Only when the next pushed row has no further boxes to push can the whole operation succeed. If a rock is hit at any time, nothing moves.
    // Treat the source with the robot as a starting row (it should just be an empty). We could set up the first row w/o it, but this lets us have the same code set up every row of locations.

    assert(map[location]! == .empty)

    let thisRow = Set<Location2D>([location])
    var locationsInRowToPush = [thisRow]

    while true {
        let prevRow = locationsInRowToPush.last!
        var nextRow = Set<Location2D>()

        for pushFrom in prevRow {
            assert(map[pushFrom]! == .boxLeft || map[pushFrom]! == .boxRight || (locationsInRowToPush.count == 1 && map[pushFrom]! == .empty))

            // The first item in the next row possibly getting pushed
            let push = pushFrom + dir
            let element = map[push]!

            if element == .wall {
                // Blocked
                return false
            }
            if element == .empty {
                continue
            }
            if element == .boxLeft {
                let neighbor = push + .right
                assert(map[neighbor]! == .boxRight)
                nextRow.insert(push)
                nextRow.insert(neighbor)
            } else {
                assert(element == .boxRight)
                let neighbor = push + .left
                assert(map[neighbor]! == .boxLeft)
                nextRow.insert(push)
                nextRow.insert(neighbor)
            }

        }

        if nextRow.isEmpty {
            // Free to push everything
            break
        }
        locationsInRowToPush.append(nextRow)
    }

    // Now push each row in reverse order, clearing the old spots as we go (since each of them might not be filled by the next row to push)
    for row in locationsInRowToPush.reversed() {
        for loc in row {
            let dest = loc + dir
            map[dest] = map[loc]!
            map[loc] = .empty
        }
    }

    // Finally, move the robot
    location = candidate

    return true
}

moves.forEach { move in
    switch move {
    case "<":
        doHorizontalMove(.left)
    case ">":
        doHorizontalMove(.right)

        // They have 0,0 at the top left
    case "^":
        doVerticalMove(.down)
    case "v":
        doVerticalMove(.up)
    default:
        fatalError()
    }

    //printMap()
}

var total = 0
map.forEach { loc, element in
    if element == .boxLeft {
        total += loc.y * 100 + loc.x
    }
}
print("\(total)")
assert(total == 1386070)

