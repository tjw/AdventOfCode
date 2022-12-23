//
//  main.swift
//  day12
//
//  Created by Timothy Wood on 12/11/22.
//

import Foundation

typealias Location = Location2D

let lines = Input.lines()

var start = Location(x: 0, y: 0)
var destination = Location(x: 0, y: 0)

let map = GridMap(elements: (0..<lines.count).map { rowIndex in
    let row = lines[rowIndex]
    return (0..<row.count).map { columnIndex in
        let charIndex = row.index(row.startIndex, offsetBy: columnIndex)
        var ch = row[charIndex]

        if ch == "S" {
            start = Location(x: columnIndex, y: rowIndex)
            ch = "a"
        } else if ch == "E" {
            destination = Location(x: columnIndex, y: rowIndex)
            ch = "a"
        }

        return ch.asciiValue! - ("a" as Character).asciiValue!
    }
})

class Path {
    var locations: [Location]

    init(start: Location) {
        locations = [start]
    }
    init(locations: [Location]) {
        self.locations = locations
    }
}

print("map \(map)")
print("start \(start)")
print("destination \(destination)")

func run(start: Location) -> Int {
    var visited = Set([start])
    var paths = [Path(start: start)]

    // paths will always have the shortest paths at the front
    while !paths.isEmpty {
        var newPaths = [Path]()
        for path in paths {
            let location = path.locations.last!
            let currentElement = map[location]!

            for direction in Location.cardinalDirections {
                let candidate = location + direction
                guard let candidateElement = map[candidate] else {
                    continue
                }
                guard !visited.contains(candidate) else {
                    continue
                }

                if currentElement + 1 < candidateElement {
                    continue // Can only move up one level, but can move down
                }

                let newPath = Path(locations: path.locations + [candidate])
                visited.insert(candidate)

                if candidate == destination {
                    return newPath.locations.count - 1 // start not counted
                }

                newPaths.append(newPath)
            }
            paths = newPaths
        }
    }

//    print("No path found")
    return Int.max
}

do {
    let result = run(start: start)
    print("\(result)")
    assert(result == 440)
}

do {
    var best: Int = Int.max

    map.forEach { location, height in
        if height == 0 {
            let result = run(start: location)
            print("location: \(location), result \(result), best \(best)")

            if best > result {
                best = result
                print("best: \(best)!")
            }
        }
    }

    print("\(best)")
    assert(best == 439)
}
