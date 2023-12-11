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
let grid = GridMap(lines: lines) { _, ch in
    Space(rawValue: ch)!
}

// Expand rows that need it
for y in (0..<grid.height).reversed() {
    let row = grid.row(y: y)
    if row.allSatisfy({ $0 == .empty}) {
        // Insert a new copy of this empty row
        grid.insert(row: row, at: y)
    }
}

// Expand columns that need it
for x in (0..<grid.width).reversed() {
    let column = grid.column(x: x)
    if column.allSatisfy({ $0 == .empty}) {
        // Insert a new copy of this empty row
        grid.insert(column: column, at: x)
    }
}

grid.forEachRow { _, row in
    print(row.map { (space: Space) in String(space.rawValue) } .joined() )
}

var galaxies = [Location2D]()

grid.forEach { location, space in
    if space == .galaxy {
        print("galaxy at \(location)")
        galaxies.append(location)
    }
}
print("\(galaxies.count) galaxies")

var result = 0
for firstIndex in 0..<galaxies.count-1 {
    for secondIndex in firstIndex+1..<galaxies.count {
        let distance = galaxies[firstIndex].manhattanDistance(to: galaxies[secondIndex])
        print("(\(firstIndex), \(secondIndex)) -> \(distance)")
        result += distance
    }
}

print("\(result)")
