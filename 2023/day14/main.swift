//
//  main.swift
//  day14
//
//  Created by Timothy Wood on 12/13/23.
//

import Foundation

enum ObjectType : GridCharacter {
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

print("Start:")
for y in (0..<grid.height).reversed() {
    let row = grid.row(y: y)
    print("\(y): \(String(row.map(\.character)))")
}
print("")


func tiltNorth() {
    func move(from start: Location2D) {
        let nextY = (start.y + 1 ..< grid.height).first(where: { grid[Location2D(x: start.x, y: $0)] != .empty }) ?? grid.height
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
                move(from: Location2D(x: x, y: y))
            }
        }
    }
}

// Instead of writing the other three tilts, rotate the map between each
// We print the grid flipped, so we aren't rotating counterclockwise
func rotateGrid(grid: GridMap<ObjectType>) {
    assert(grid.width == grid.height) // Our case happens to be square
    let size = grid.width
    let original = GridMap(elements: grid.elements)

    // shouldn't be needed if the mapping is right
    grid.forEach { location, _ in grid[location] = .empty }

    original.forEach { location, _ in
        let newLocation = Location2D(x: location.y, y: size - location.x - 1)
        grid[newLocation] = original[location]
    }
}

func weight(grid: GridMap<ObjectType>) -> Int {
    var result = 0

    grid.forEach { location, object in
        if object == .rollingRock {
            result += location.y + 1
        }
    }

    return result
}

do {
    tiltNorth()

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
    assert(result == 105208)
}


do {
    var gridStateToCycle = [String:Int]()
    var cycleToWeight = [Int]()

    var cycle = 0
    var period = 0

    while cycle < 1000 {
        tiltNorth()
        rotateGrid(grid: grid)

        tiltNorth()
        rotateGrid(grid: grid)

        tiltNorth()
        rotateGrid(grid: grid)

        tiltNorth()
        rotateGrid(grid: grid)

        let weight = weight(grid: grid)
        print("Cycle \(cycle + 1), weight \(weight):")
//        for y in (0..<grid.height).reversed() {
//            let row = grid.row(y: y)
//            print("\(y): \(String(row.map(\.character)))")
//        }

        let key = grid.stringRepresentation
        if let previous = gridStateToCycle[key] {
            print("  was in this state previously on cycle \(previous), period of \(cycle - previous)")
            period = cycle - previous
            cycleToWeight.append(weight)
            break
        }
        gridStateToCycle[key] = cycle
        cycleToWeight.append(weight)
        cycle += 1
    }

    let remainder = (1000000000 - cycle - 1) % period
    print("remainder = \(remainder)")

    let orbit = Array(cycleToWeight[cycleToWeight.count - (period + 1) ..< cycleToWeight.count])
    assert(orbit.count == period + 1)

    print("orbit \(orbit)")
    print("orbit[\(remainder)] = \(orbit[remainder])")

    assert(orbit[remainder] == 102943)
}
