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
var grid = HashMap2D(defaultElement: Space.empty)
var galaxyLocations = [Location2D]()

for y in 0..<lines.count {
    var line = lines[y][...]
    for x in 0..<line.count {
        let space = Space(rawValue:line.first!)!
        if space == .galaxy {
            let location = Location2D(x: x, y: y)
            grid[location] = space
            print("Galaxy at \(location)")
            galaxyLocations.append(location)
        }
        line = line.dropFirst()
    }
}

// Expand rows that need it
do {
    let bounds = grid.bounds

    galaxyLocations = []

    var expansion = 0
    for y in bounds.y..<bounds.y + bounds.height {
        // If this row is empty, increase the total expansion
        let rowRange = bounds.x..<bounds.x + bounds.width
        if rowRange.allSatisfy({ grid[Location2D(x: $0, y: y)] == .empty }) {
            expansion += 1
        } else {
            // Shift all the galaxies in this row by the expansion so far. Can't update in place since that would push galaxies into locations that would get processed again.
            for x in rowRange {
                if grid[Location2D(x: x, y: y)] == .galaxy {
                    galaxyLocations.append(Location2D(x: x, y: y + expansion))
                }
            }
        }
    }

    // Rebuild the map
    grid.removeAll()
    galaxyLocations.forEach { grid[$0] = .galaxy }
}

// Expand columns that need it
do {
    let bounds = grid.bounds

    galaxyLocations = []

    var expansion = 0

    for x in bounds.x ..< bounds.x + bounds.width {
        // If this column is empty, increase the total expansion
        let columnRange = bounds.y ..< bounds.y + bounds.height
        if columnRange.allSatisfy({ grid[Location2D(x: x, y: $0)] == .empty }) {
            expansion += 1
        } else {
            // Shift all the galaxies in this column by the expansion so far. Can't update in place since that would push galaxies into locations that would get processed again.
            for y in columnRange {
                if grid[Location2D(x: x, y: y)] == .galaxy {
                    galaxyLocations.append(Location2D(x: x + expansion, y: y))
                }
            }
        }
    }

    // Rebuild the map
    grid.removeAll()
    galaxyLocations.forEach { grid[$0] = .galaxy }
}


//grid.forEachRow { _, row in
//    print(row.map { (space: Space) in String(space.rawValue) } .joined() )
//}

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
//assert(result == 9734203)
