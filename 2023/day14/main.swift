//
//  main.swift
//  day14
//
//  Created by Timothy Wood on 12/13/23.
//

import Foundation

enum ObjectType {
    case rollingRock
    case fixedRock
    case empty

    init(character: Character) {
        switch character {
        case "O":
            self = .rollingRock
        case "#":
            self = .fixedRock
        case ".":
            self = .empty
        default:
            fatalError()
        }
    }

    var character: Character {
        switch self {
        case .rollingRock:
            return "O"
        case .fixedRock:
            return "#"
        case .empty:
            return "."
        }
    }
}

let lines = Array(Input.lines().reversed()) // Flip the map
let grid = GridMap<ObjectType>(lines: lines) { ObjectType(character: $1) }

//print("Start:")
//for y in (0..<grid.height).reversed() {
//    let row = grid.row(y: y)
//    print("\(y): \(String(row.map(\.character)))")
//}
//print("")

do {

    func moveUp(from start: Location2D) {
        var nextY = start.y + 1
        while nextY < grid.height {
            if grid[Location2D(x: start.x, y: nextY)] != .empty {
                break
            }
            nextY += 1
        }

        if nextY != start.y {
            grid[Location2D(x: start.x, y: start.y)] = .empty
            grid[Location2D(x: start.x, y: nextY - 1)] = .rollingRock
            return
        }
    }

    // Move rocks north (up), starting on the next to top row (round rocks in the top row have no further to go)
    for y in (0..<grid.height-1).reversed() {
        let row = grid.row(y: y)
        for x in 0..<grid.width {
            let object = row[x]
            if object == .rollingRock {
                //print("Move up from \(Location2D(x: x, y: y)):")
                moveUp(from: Location2D(x: x, y: y))
//                for y in (0..<grid.height).reversed() {
//                    let row = grid.row(y: y)
//                    print("\(y): \(String(row.map(\.character)))")
//                }
//                print("")
            }
        }
    }

    print("End:")
    for y in (0..<grid.height).reversed() {
        let row = grid.row(y: y)
        print("\(y): \(String(row.map(\.character)))")
    }

    var result = 0

    grid.forEach { location, object in
        if object == .rollingRock {
            result += location.y + 1
        }
    }
    print("\(result)")
}


