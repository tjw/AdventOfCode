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
    print("location \(location)")
    print("dir \(dir)")
    print("candidate \(candidate)")
    print("map width \(map.width), height \(map.height)")
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
                printMap()
            }
            map[candidate] = .empty
            location = candidate
            printMap()
            return true
        }
    }
}

func doVerticalMove(_ dir: Location2D) -> Bool {
    fatalError()
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

    /*
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
     */

    printMap()
}

/*
 var total = 0
 map.forEach { loc, element in
 if element == .box {
 total += loc.y * 100 + loc.x
 }
 }
 print("\(total)")
 */
