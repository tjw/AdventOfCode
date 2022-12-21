//
//  main.swift
//  day17
//
//  Created by Timothy Wood on 12/20/22.
//

import Foundation

// Describe rocks as a list of offsets from their bottom/left corner
let rocks: [[Location]] = [
    // Horizontal line
    [
        Location(x: 0, y: 0),
        Location(x: 1, y: 0),
        Location(x: 2, y: 0),
        Location(x: 3, y: 0),
    ],

    // Plus
    [
        Location(x: 1, y: 0),
        Location(x: 0, y: 1),
        Location(x: 1, y: 1),
        Location(x: 2, y: 1),
        Location(x: 1, y: 2),
    ],

    // Backwards L
    [
        Location(x: 0, y: 0),
        Location(x: 1, y: 0),
        Location(x: 2, y: 0),
        Location(x: 2, y: 1),
        Location(x: 2, y: 2),
    ],

    // Vertical Line
    [
        Location(x: 0, y: 0),
        Location(x: 0, y: 1),
        Location(x: 0, y: 2),
        Location(x: 0, y: 3),
    ],

    // Square
    [
        Location(x: 0, y: 0),
        Location(x: 1, y: 0),
        Location(x: 0, y: 1),
        Location(x: 1, y: 1),
    ]
]

enum MapElement : String {
    case air = "."
    case stone = "#"
    case dropping = "@"
}

let map = HashMap<MapElement>(defaultElement: .air)
let width = 7

// The floor is at y = 0
var highestRock = 0

var rocksDropped = 0
let rocksLimit = 2022

var inputOffset = 0
let input: [Character] = Array(Input.lines().first!)

func canMove(to location: Location, rock: [Location]) -> Bool {
    for offset in rock {
        let pieceLocation = location + offset

        if pieceLocation.x < 0 || pieceLocation.x >= 7 {
            // Walls
            return false
        }
        if pieceLocation.y <= 0 {
            // Floor
            return false
        }
        if map[pieceLocation] == .stone {
            return false
        }
    }

    return true
}

// Returns the higest Y offset on the rock
func paint(rock: [Location], at location: Location, value: MapElement) -> Int {
    var highestY = 0

    for offset in rock {
        let rockLocation = location + offset
        highestY = max(highestY, rockLocation.y)

        map[rockLocation] = value
    }

    return highestY
}

func printMap() {
    var y = highestRock + 4 + 4 // tallest possible dropping rock + starting offset

    while y > 0 {
        print("|", terminator: "")
        for x in 0..<7 {
            print(map[Location(x: x, y: y)].rawValue, terminator: "")
        }

        if y == highestRock {
            print("|<--")
        } else {
            print("|")
        }

        y -= 1
    }
    print("+-------+")
}

while rocksDropped < rocksLimit {
    let rock = rocks[rocksDropped % rocks.count]
    print("\(rocksDropped) \(rock)")
    rocksDropped += 1

    var location = Location(x: 2, y: highestRock + 4)
    _ = paint(rock: rock, at: location, value: .dropping)
    //printMap()

    while true {
        // Process the jet
        let jet = input[inputOffset % input.count]
        inputOffset += 1

        if jet == "<" {
            if canMove(to: location + .left, rock: rock) {
                _ = paint(rock: rock, at: location, value: .air)
                location += .left
                _ = paint(rock: rock, at: location, value: .dropping)
            }
        } else if jet == ">" {
            if canMove(to: location + .right, rock: rock) {
                _ = paint(rock: rock, at: location, value: .air)
                location += .right
                _ = paint(rock: rock, at: location, value: .dropping)
            }
        }
        //printMap()

        // Move down
        if canMove(to: location + .down, rock: rock) {
            _ = paint(rock: rock, at: location, value: .air)
            location += .down
            _ = paint(rock: rock, at: location, value: .dropping)
            //printMap()
        } else {
            // Turn to stone
            highestRock = max(highestRock, paint(rock: rock, at: location, value: .stone))
            //printMap()
            break
        }
    }
}

print("rocksDropped \(rocksDropped)")
print("highestRock \(highestRock)")
assert(highestRock == 3177)

// 1_000_000_000_000
