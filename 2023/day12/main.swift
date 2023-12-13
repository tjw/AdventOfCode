//
//  main.swift
//  day12
//
//  Created by Timothy Wood on 12/11/23.
//

import Foundation

let lines = Input.lines()

enum Condition : Character, RawRepresentable {
    case unknown = "?"
    case operational = "."
    case damaged = "#"
}

func pack(level: Int, conditions: Array<Condition>.SubSequence, damagedLengths: Array<Int>.SubSequence) -> Int {
    print("\(indent(level))\((conditions.map { String($0.rawValue) }).joined()) \(damagedLengths)")

    if conditions.isEmpty {
        if damagedLengths.isEmpty {
            print("\(indent(level + 1))at end -> 1")
            return 1
        } else {
            print("\(indent(level + 1))expecting more damage -> 0")
            return 0
        }
    }

    switch conditions.first! {
    case .operational:
        // Can't pack any damaged length into an operational spot
        return pack(level: level + 1, conditions: conditions.dropFirst(), damagedLengths: damagedLengths)
    case .damaged:
        // If this is guaranteed damaged, need the first damage range to consume it
        guard let firstLength = damagedLengths.first else {
            print("\(indent(level + 1))Have damage in the conditions, but no lengths left -> 0")
            return 0
        }
        if firstLength == 1 {
            // Entirely consumed. Need the next condition to able to be mapped to operational otherwise it'd be merged
            let remaining = conditions.dropFirst()
            guard remaining.first != .damaged else {
                print("\(indent(level + 1))XXX damage length of 1, but next is \(remaining.first!) -> 0")
                return 0
            }
            return pack(level: level + 1, conditions: remaining.dropFirst(), damagedLengths: damagedLengths.dropFirst())
        } else {
            // Used up one unit of the first damaged length
            return pack(level: level + 1, conditions: conditions.dropFirst(), damagedLengths: [firstLength - 1] + damagedLengths.dropFirst())
        }
    case .unknown:
        // Can either assume this spot is damaged or not
        let damagedCount = pack(level: level + 1, conditions: [.damaged] + conditions.dropFirst(), damagedLengths: damagedLengths)
        let undamagedCount = pack(level: level + 1, conditions: [.operational] + conditions.dropFirst(), damagedLengths: damagedLengths)

        return undamagedCount + damagedCount
    }

}

var result = 0

for line in lines {
    let components = line.split(separator: " ")
    let conditions = components[0].map { Condition(rawValue: $0)! }
    let damagedLengths = String(components[1]).numbers(separatedBy: CharacterSet(charactersIn: ","))

    let count = pack(level: 0, conditions: conditions[...], damagedLengths: damagedLengths[...])
    print("~~~~ \(line) -> \(count)")
    result += count
}

print("\(result)")
// 114033 too high with case that failed on test input
