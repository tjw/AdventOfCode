//
//  main.swift
//  day17
//
//  Created by Timothy Wood on 12/20/22.
//

import Foundation

typealias Location = Location2D
typealias HashMap = HashMap2D

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

// Returns the relative height from the previous max height in the map
func process(map: HashMap<MapElement>, rocksLimit: Int) -> [Int] {
    // The floor is at y = 0

    // Allow for the map having been partially filled already
    let bounds = map.bounds
    let startingHighestRow: Int
    if bounds.height > 0 {
        startingHighestRow = bounds.y + bounds.height - 1
    } else {
        startingHighestRow = 0
    }
    //print("startingHighestRow \(startingHighestRow)")

    var relativeHeights = [Int]()
    var highestRock = startingHighestRow

    //print(map: map, highestRock: highestRock, range: max(1, highestRock - 5)...(highestRock + 8))

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

        relativeHeights.append(highestRock - startingHighestRow)
    }

    return relativeHeights
}

if false {
    let map = HashMap<MapElement>(defaultElement: .air)

    let result = process(map: map, rocksLimit: 2022).last!

    print("result \(result)")
    assert(result == 3177)
}

if true {
    let map = HashMap<MapElement>(defaultElement: .air)

    // Experimenting with trying to find a periodic cycle of height added by adding enough rocks to get back to the "start" modulo the input size and rock type count. The first iteration will be special since it lands on a flat floor instead of a craggy top. But experimenting beyond that, my input ends up increasing height with a cycle period of two.

    // Each repetition is rock count * input length rocks dropped (5 * 10091) = 50455
    // For the test input, the first cycle is 308, and then every cycle after that is 280.
    // For the real input, the first cycle is 78982 and then a cycle of 78973 and 78980 after that.

    let rocksPerCycle = input.count * rocks.count

    // Print out a few "small" cycles looking for the full orbit
    for rep in 0..<23 {
        let height = process(map: map, rocksLimit: rocksPerCycle).last!
        print("rep \(rep) bounds \(map.bounds.height), added height \(height)")
    }

    // Need to do 1_000_000_000_000 operations, but that will overflow. Break it up in to 1_000_000 * 1_000_000 for a simplified 'big int' approach that will be easily interpreted when printed out
    var rocks2 = 1_000_000, rocks1 = 0
    var height2 = 0, height1 = 0
    while rocks2 > 0 || rocks1 >= rocksPerCycle {
        //print("rocks \(rocks2) \(rocks1), height \(height2) \(height1)")

        // TODO: Upscale the step size to be closer to 1e6 to require fewer inner iterations

        if rocks1 < rocksPerCycle {
            rocks2 -= 1
            rocks1 += 1_000_000
        }
        rocks1 -= rocksPerCycle

        height1 += 308
        if height1 >= 1_000_000 {
            height1 -= 1_000_000
            height2 += 1
        }
    }

    // TODO: Handle the last bit by indexing into the array of height increases for the full cycle.


    // For test input, looking for 1_514_285 714_288

    print("rocks \(rocks2) \(rocks1)")
    print("height \(height2) \(height1)")
}


