//
//  main.swift
//  day4
//
//  Created by Timothy Wood on 12/8/22.
//

import Foundation

let lines = Input.lines()

extension ClosedRange where Element == Int {
    init(string: String) {
        let components = string.split(separator: "-")
        let min = Int(components[0])!
        let max = Int(components[1])!

        self = min...max
    }
}

struct Assignment {
    let elf0: ClosedRange<Int>
    let elf1: ClosedRange<Int>

    init(line: String) {
        let components = line.split(separator: ",")
        elf0 = ClosedRange(string: String(components[0]))
        elf1 = ClosedRange(string: String(components[1]))
    }
}

extension ClosedRange {
    func contains(other: ClosedRange) -> Bool {
        return contains(other.lowerBound) && contains(other.upperBound)
    }
}

let assignments = lines.map { Assignment(line: $0) }

do {
    let count = assignments.filter { a in
        a.elf0.contains(other: a.elf1) || a.elf1.contains(other: a.elf0)
    }.count
    print("\(count)")
    assert(count == 602)
}

do {
    let count = assignments.filter { a in
        a.elf0.overlaps(a.elf1)
    }.count
    print("\(count)")
    assert(count == 891)
}
