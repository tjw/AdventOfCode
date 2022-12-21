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

let width = 7
let input: [Character] = Array(Input.lines().first!.trimmingCharacters(in: .whitespacesAndNewlines))
print("input length \(input.count)")

func canMove(rock: [Location], to location: Location, map: HashMap<MapElement>) -> Bool {
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
func paint(map: HashMap<MapElement>, rock: [Location], at location: Location, value: MapElement) -> Int {
    var highestY = 0

    for offset in rock {
        let rockLocation = location + offset
        highestY = max(highestY, rockLocation.y)

        map[rockLocation] = value
    }

    return highestY
}

func clear(map: HashMap<MapElement>, rock: [Location], at location: Location) {
    for offset in rock {
        map.clear(location: location + offset)
    }
}

func print(map: HashMap<MapElement>, highestRock: Int, range range_: ClosedRange<Int>? = nil) {
    let range: ClosedRange<Int>
    if let range_ {
        range = range_
    } else {
        let y = highestRock + 4 + 4 // tallest possible dropping rock + starting offset
        range = 1...y
    }

    for y in range.reversed() {
        print("\(String(format: "% 4d", y)): |", terminator: "")
        for x in 0..<7 {
            print(map[Location(x: x, y: y)].rawValue, terminator: "")
        }

        if y == highestRock {
            print("|<--")
        } else {
            print("|")
        }
    }
    print("+-------+")
}

func process(map: HashMap<MapElement>, rocksLimit: Int) -> Int {
    // The floor is at y = 0

    // Allow for the map having been partially filled already
    let bounds = map.bounds
    var highestRock = bounds.y + bounds.height

    print(map: map, highestRock: highestRock, range: max(1, highestRock - 5)...(highestRock + 8))

    var rocksDropped = 0
    var inputOffset = 0

    while rocksDropped < rocksLimit {
        let rock = rocks[rocksDropped % rocks.count]
        rocksDropped += 1

        var location = Location(x: 2, y: highestRock + 4)
        _ = paint(map: map, rock: rock, at: location, value: .dropping)
        //printMap()

        while true {
            // Process the jet
            let jet = input[inputOffset % input.count]
            inputOffset += 1

            if jet == "<" {
                if canMove(rock: rock, to: location + .left, map: map) {
                    clear(map: map, rock: rock, at: location)
                    location += .left
                    _ = paint(map: map, rock: rock, at: location, value: .dropping)
                }
            } else if jet == ">" {
                if canMove(rock: rock, to: location + .right, map: map) {
                    clear(map: map, rock: rock, at: location)
                    location += .right
                    _ = paint(map: map, rock: rock, at: location, value: .dropping)
                }
            }
            //printMap()

            // Move down
            if canMove(rock: rock, to: location + .down, map: map) {
                clear(map: map, rock: rock, at: location)
                location += .down
                _ = paint(map: map, rock: rock, at: location, value: .dropping)
                //printMap()
            } else {
                // Turn to stone
                highestRock = max(highestRock, paint(map: map, rock: rock, at: location, value: .stone))
                //printMap()
                break
            }
        }
    }

    return highestRock
}

if false {
    let map = HashMap<MapElement>(defaultElement: .air)

    let result = process(map: map, rocksLimit: 2022)

    print("result \(result)")
    assert(result == 3177)
}

if true {
    let map = HashMap<MapElement>(defaultElement: .air)

    var previousHeight = 0

    for rep in 0..<100 {
        let height = process(map: map, rocksLimit: input.count * rocks.count)
        print("rep \(rep) added height \(height - previousHeight)")
        previousHeight = height
    }

    // each rep is rock count * input length rocks dropped (5 * 10091) = 50455
    // rep 0 is 78982
    // rep 1 is 78973
    // rep 2 is 78980
    // following reps are rep 1 and 2 cycled infinitely
}


// 1_000_000_000_000
