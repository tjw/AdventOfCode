//
//  main.swift
//  day4
//
//  Created by Timothy Wood on 12/3/24.
//

import Foundation

enum Letters : String {
    case X
    case M
    case A
    case S
}

let grid = GridMap(lines: Input.lines()) { _, ch in Letters(rawValue: String(ch))! }

do {
    var count = 0

    grid.bounds.forEach { location in
        Location2D.allDirections.forEach { direction in
            // Could early out by checking validity going along (or at least the first character)
            var position = location
            var result = ""

            (0..<4).forEach { _ in
                if grid.contains(location: position) {
                    result.append(grid[position]!.rawValue)
                    position += direction
                }
            }

            if result == "XMAS" {
                count += 1
            }
        }
    }

    print("\(count)")
    assert(count == 2549)
}

do {
    var count = 0

    // Need a specific order that loops around the center
    let directions: [Location2D] = [.leftUp, .rightUp, .rightDown, .leftDown]

    grid.bounds.forEach { location in
        guard grid[location] == .A else { return }

        var result = ""
        directions.forEach { direction in
            let position = location + direction
            if grid.contains(location: position) {
                result.append(grid[position]!.rawValue)
            }
        }

        switch result {
        case "MMSS", "MSSM", "SSMM", "SMMS":
            count += 1
        default:
            break
        }
    }

    print("\(count)")
    assert(count == 2003)
}

