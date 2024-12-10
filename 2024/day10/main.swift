//
//  main.swift
//  day10
//
//  Created by Timothy Wood on 12/9/24.
//

import Foundation

var trailheads = [Location2D]()
let map = GridMap<Int>(lines: Input.lines()) { loc, ch in
    let height = Int(String(ch))!
    if height == 0 {
        trailheads.append(loc)
    }
    return height
}

do {
    // Count the number of 9s reachable. Number of independent paths doesn't matter, apparently.
    func follow(loc: Location2D) -> Set<Location2D> {
        let value = map[loc]!

        var nines = Set<Location2D>()
        Location2D.cardinalDirections.forEach { dir in
            let candidate = loc + dir
            guard let dest = map[candidate] else { return }
            if dest == value + 1 {
                if dest == 9 {
                    nines.insert(candidate)
                } else {
                    nines.formUnion(follow(loc: candidate))
                }
            }
        }

        return nines
    }

    var total = 0
    for trailhead in trailheads {
        let nines = follow(loc: trailhead)
        print("trailhead \(trailhead) -> nines \(nines)")
        total += nines.count
    }

    print("\(total)")
    assert(total == 717)
}

do {
    // In part two, the rating of a trail is the disinct number of paths starting from it and reaching some 9.

    func rating(loc: Location2D) -> Int {
        assert(map[loc]! == 0)

        var current = [[loc]]
        for height in 1...9 {
            var next = [[Location2D]]()

            for path in current {
                Location2D.cardinalDirections.forEach { dir in
                    let last = path.last!
                    let candidate = last + dir
                    guard let dest = map[candidate] else { return }
                    if dest == height {
                        next.append(path + [candidate])
                    }
                }
            }

            current = next
        }

        return current.count
    }

    var total = 0
    for trailhead in trailheads {
        let rating = rating(loc: trailhead)
        print("trailhead \(trailhead) -> rating \(rating)")
        total += rating
    }

    print("\(total)")
    assert(total == 1686)
}
