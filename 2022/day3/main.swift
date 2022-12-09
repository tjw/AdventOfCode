//
//  main.swift
//  day3
//
//  Created by Timothy Wood on 12/8/22.
//

import Foundation

extension Character {
    var priority: UInt8 {
        let value = asciiValue!

        if self >= "a" && self <= "z" {
            return value - ("a" as Character).asciiValue! + 1
        }
        if self >= "A" && self <= "Z" {
            return value - ("A" as Character).asciiValue! + 27
        }

        fatalError()
    }
}

struct Rucksack {
    let compartment0: [UInt8]
    let compartment1: [UInt8]

    init(line: String) {
        let count = line.count
        assert(count % 2 == 0)

        let middle = line.index(line.startIndex, offsetBy: count/2)
        let first = line[line.startIndex..<middle]
        let second = line[middle..<line.endIndex]

        compartment0 = first.map { $0.priority }
        compartment1 = second.map { $0.priority }
    }

    var overlap: UInt8 {
        let intersection = Set(compartment0).intersection(Set(compartment1))
        assert(intersection.count == 1)
        return intersection.first!
    }
}

let lines = Input.lines()

let rucksacks = Input.lines().map {
    return Rucksack(line: $0)
}

do {
    let total = rucksacks.reduce(0, { $0 + Int($1.overlap) })
    print("\(total)")
    assert(total == 7878)
}

do {
    assert(rucksacks.count % 3 == 0)

    var total = 0
    let count = rucksacks.count
    var group = 0

    while group < count {
        let r0 = rucksacks[group + 0]
        let r1 = rucksacks[group + 1]
        let r2 = rucksacks[group + 2]

        let overlap = Set(r0.compartment0 + r0.compartment1)
            .intersection(Set(r1.compartment0 + r1.compartment1))
            .intersection(Set(r2.compartment0 + r2.compartment1))

        assert(overlap.count == 1)
        total += Int(overlap.first!)

        group += 3
    }
    print("\(total)")
    assert(total == 2760)
}
