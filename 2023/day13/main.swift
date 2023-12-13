//
//  main.swift
//  day13
//
//  Created by Timothy Wood on 12/12/23.
//

import Foundation

enum LandType : Character, RawRepresentable {
    case ash = "."
    case rock = "#"
}

var maps = [GridMap<LandType>]()

do {
    let lines = Input.lines(includeEmpty: true)
    var buffer = [String]()

    for line in lines {
        if line.isEmpty {
            let map = GridMap(lines: buffer) { _, ch in LandType(rawValue: ch)! }
            maps.append(map)
            buffer = []
        } else {
            buffer.append(line)
        }
    }

    if !buffer.isEmpty {
        let map = GridMap(lines: buffer) { _, ch in LandType(rawValue: ch)! }
        maps.append(map)
    }
}

extension Array where Element : Equatable {
    func differenceCount(from other: Array<Element>) -> Int {
        assert(self.count == other.count)
        return (0..<count).reduce(0, { $0 + (self[$1] == other[$1] ? 0 : 1) })
    }
}

// Checks y and y+1 and outward from there until an edge is hit or there is a difference
func checkMirror(map: GridMap<LandType>, y: Int, maximumDifferences: Int = 0) -> Bool {
    var step = 0
    var totalDifferences = 0

    while y - step >= 0 && y + 1 + step < map.height {
        let row0 = map.row(y: y - step)
        let row1 = map.row(y: y + 1 + step)

        totalDifferences += row0.differenceCount(from: row1)
        if totalDifferences > maximumDifferences {
            return false
        }

        step += 1
    }

    return true
}

// Likewise but for columns
func checkMirror(map: GridMap<LandType>, x: Int, maximumDifferences: Int = 0) -> Bool {
    var step = 0
    var totalDifferences = 0

    while x - step >= 0 && x + 1 + step < map.width {
        let column0 = map.column(x: x - step)
        let column1 = map.column(x: x + 1 + step)

        totalDifferences += column0.differenceCount(from: column1)
        if totalDifferences > maximumDifferences {
            return false
        }

        step += 1
    }

    return true
}

func checkMirrorRows(map: GridMap<LandType>, maximumDifferences: Int = 0) -> IndexSet {
    var result = IndexSet()
    for y in 0..<map.height-1 {
        let mirror = checkMirror(map: map, y: y, maximumDifferences: maximumDifferences)
        print("y: \(y + 1), mirror: \(mirror)")
        if mirror {
            result.insert(y)
        }
    }
    return result
}

func checkMirrorColumns(map: GridMap<LandType>, maximumDifferences: Int = 0) -> IndexSet {
    var result = IndexSet()
    for x in 0..<map.width-1 {
        let mirror = checkMirror(map: map, x: x, maximumDifferences: maximumDifferences)
        print("x: \(x + 1), mirror: \(mirror)")
        if mirror {
            result.insert(x)
        }
    }
    return result
}

// NOTE: Assuming there is only one valid answer for each map

do {
    var rowsSum = 0
    var columnsSum = 0

    for map in maps {
        let mirrorRows = checkMirrorRows(map: map)
        let mirrorColumns = checkMirrorColumns(map: map)

        assert(mirrorRows.count + mirrorColumns.count == 1)

        if let row = mirrorRows.first {
            print("row: \(row + 1)")
            rowsSum += (row + 1) // 1 indexed
        } else {
            let column = mirrorColumns.first!
            print("column: \(column + 1)")
            columnsSum += (column + 1) // 1 indexed
        }
    }

    let result = 100 * rowsSum + columnsSum
    print("\(result)")
    assert(result == 33728)
}

do {
    var rowsSum = 0
    var columnsSum = 0

    for map in maps {
        let mirrorRows0 = checkMirrorRows(map: map, maximumDifferences: 0)
        let mirrorRows1 = checkMirrorRows(map: map, maximumDifferences: 1)
        let mirrorColumns0 = checkMirrorColumns(map: map, maximumDifferences: 0)
        let mirrorColumns1 = checkMirrorColumns(map: map, maximumDifferences: 1)

        let mirrorRows = mirrorRows1.subtracting(mirrorRows0)
        let mirrorColumns = mirrorColumns1.subtracting(mirrorColumns0)

        assert(mirrorRows.count + mirrorColumns.count == 1)

        if let row = mirrorRows.first {
            print("row: \(row + 1)")
            rowsSum += (row + 1) // 1 indexed
        } else {
            let column = mirrorColumns.first!
            print("column: \(column + 1)")
            columnsSum += (column + 1) // 1 indexed
        }
    }

    let result = 100 * rowsSum + columnsSum
    print("\(result)")
    assert(result == 28235)
}
