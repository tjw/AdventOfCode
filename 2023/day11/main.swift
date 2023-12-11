//
//  main.swift
//  day11
//
//  Created by Timothy Wood on 12/10/23.
//

import Foundation

enum Space : Character, RawRepresentable {
    case empty = "."
    case galaxy = "#"
}

let lines = Input.lines()
var galaxyLocations = [Location2D]()
let expansionRate = 1000000

for y in 0..<lines.count {
    var line = lines[y][...]
    for x in 0..<line.count {
        let space = Space(rawValue:line.first!)!
        if space == .galaxy {
            let location = Location2D(x: x, y: y)
            print("Galaxy at \(location)")
            galaxyLocations.append(location)
        }
        line = line.dropFirst()
    }
}

// Expand rows that need it
do {
    // Sort the galaxies with minimum y coordinate first
    galaxyLocations.sort { $0.y < $1.y }

    var expansion = 0
    var previousY = galaxyLocations.first!.y

    for galaxyIndex in 0..<galaxyLocations.count {
        let galaxy = galaxyLocations[galaxyIndex]
        if galaxy.y == previousY || galaxy.y == previousY + 1 {
            // Still in the same row or stepping to the next row with no empty row between. No update to expansion
        } else {
            // One or more empty rows
            expansion += (galaxy.y - previousY - 1) * (expansionRate - 1)
        }

        galaxyLocations[galaxyIndex] = Location2D(x: galaxy.x, y: galaxy.y + expansion)
        previousY = galaxy.y
    }
}

// Expand columns that need it
do {
    // Sort the galaxies with minimum x coordinate first
    galaxyLocations.sort { $0.x < $1.x }

    var expansion = 0
    var previousX = galaxyLocations.first!.x

    for galaxyIndex in 0..<galaxyLocations.count {
        let galaxy = galaxyLocations[galaxyIndex]
        if galaxy.x == previousX || galaxy.x == previousX + 1 {
            // Still in the same column or stepping to the next column with no empty column between. No update to expansion
        } else {
            // One or more empty column
            expansion += (galaxy.x - previousX - 1) * (expansionRate - 1)
        }

        galaxyLocations[galaxyIndex] = Location2D(x: galaxy.x + expansion, y: galaxy.y)
        previousX = galaxy.x
    }
}

print("\(galaxyLocations.count) galaxies")

var result = 0
for firstIndex in 0..<galaxyLocations.count-1 {
    for secondIndex in firstIndex+1..<galaxyLocations.count {
        let distance = galaxyLocations[firstIndex].manhattanDistance(to: galaxyLocations[secondIndex])
        print("(\(firstIndex), \(secondIndex)) -> \(distance)")
        result += distance
    }
}

print("\(result)")
//assert(result == 9734203) // part 1
//assert(result == 568914596391) // part 2
