//
//  main.swift
//  day19
//
//  Created by Timothy Wood on 12/18/24.
//

import Foundation

let sections = Input.sections()
let availableTowels = sections[0][0].split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
let patterns = sections[1]

print("availableTowels \(availableTowels)")

struct Match {
    var usedTowels: [String] = []
    var remainder: Substring

    func step() -> [Match] {
        assert(!remainder.isEmpty)

        //print("Checking \(remainder)")
        return availableTowels.compactMap { towel in
            //print("  - \(towel)")
            if remainder.hasPrefix(towel) {
                //print("  - \(towel) matches")
                return Match(usedTowels: usedTowels + [towel], remainder: remainder.trimmingPrefix(towel))
            } else {
                return nil
            }
        }
    }

    var complete: Bool {
        return remainder.isEmpty
    }
}

var remaining = patterns.map { Match(remainder: $0[...]) }

var solutions = [Match]()
while !remaining.isEmpty {
    let next = remaining.flatMap { $0.step() }

    solutions += next.filter { $0.complete }
    remaining = next.filter { !$0.complete }
    print("\(remaining.count)")
}

print("\(solutions.count)")

// Might be possible to make a given pattern mutiple ways?
var uniqueSolutions = Set<String>()

for solution in solutions {
    //print("\(solution.usedTowels.joined(separator: "")) -- \((solution.usedTowels))")
    uniqueSolutions.insert(solution.usedTowels.joined(separator: ""))
}
print("\(uniqueSolutions.count)")
