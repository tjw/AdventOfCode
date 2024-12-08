//
//  main.swift
//  day8
//
//  Created by Timothy Wood on 12/7/24.
//

import Foundation

var nodeLocations = [Character:[Location2D]]()

// The map will only contain the antinode counts, at least for part 1
let map = GridMap<Int>(lines: Input.lines()) { loc, ch in
    if ch != "." {
        var locations = nodeLocations[ch] ?? []
        locations.append(loc)
        nodeLocations[ch] = locations
    }
    return 0
}

for frequency in nodeLocations.keys.sorted() {
    let locations = nodeLocations[frequency]!

    // Add an antinode for every pairing.
    let count = locations.count
    for indexA in 0..<count {
        for indexB in indexA+1..<count {
            assert(indexA != indexB)

            let a = locations[indexA]
            let b = locations[indexB]

            print("\(frequency) at \(a) and \(b)")
            let dist1 = b - a
            let anti1 = a + dist1 + dist1
            if map.contains(location: anti1) {
                map[anti1]! = map[anti1]! + 1
            }

            let dist2 = a - b
            let anti2 = b + dist2 + dist2
            if map.contains(location: anti2) {
                map[anti2]! = map[anti2]! + 1
            }
        }
    }
}

do {
    var result = 0
    map.forEach { _, count in
        if count > 0 {
            result += 1
        }
    }
    print("\(result)")
    assert(result == 305)
}


// Can use the same map for part 2 since the result is only how *many* antinodes there are, and all the previous antinodes are still valid
for frequency in nodeLocations.keys.sorted() {
    let locations = nodeLocations[frequency]!

    // Add an antinode for every pairing.
    let count = locations.count
    for indexA in 0..<count {
        for indexB in indexA+1..<count {
            assert(indexA != indexB)

            let a = locations[indexA]
            let b = locations[indexB]

            print("\(frequency) at \(a) and \(b)")
            let dist1 = b - a
            var anti1 = a
            while map.contains(location: anti1) {
                map[anti1]! = map[anti1]! + 1
                anti1 += dist1
            }

            let dist2 = a - b
            var anti2 = b
            while map.contains(location: anti2) {
                map[anti2]! = map[anti2]! + 1
                anti2 += dist2
            }
        }
    }
}

do {
    var result = 0
    map.forEach { _, count in
        if count > 0 {
            result += 1
        }
    }
    print("\(result)")
    assert(result == 1150)
}
