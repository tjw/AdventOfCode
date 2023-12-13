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

func pack(length: Int, prefix: String, conditions: Array<Condition>.SubSequence, damagedLengths: Array<Int>.SubSequence) -> [String] {
    // Recursion shouldn't change the total length of the possible pending output and remaining conditions
    assert(prefix.count + conditions.count == length)

    print("\(prefix) -- \((conditions.map { String($0.rawValue) }).joined()) \(damagedLengths)")

    if conditions.isEmpty {
        if damagedLengths.isEmpty {
            print("\(indent(prefix.count * 2 + 1))at end -> 1")
            return [prefix]
        } else {
            print("\(indent(prefix.count * 2 + 1))expecting more damage -> 0")
            return []
        }
    }

    let current = conditions.first!
    switch current {
    case .operational:
        // Can't pack any damaged length into an operational spot
        return pack(length: length, prefix: prefix + String(current.rawValue), conditions: conditions.dropFirst(), damagedLengths: damagedLengths)
    case .damaged:
        // If this is guaranteed damaged, need the first damage range to consume it
        guard let firstLength = damagedLengths.first else {
            print("\(indent(prefix.count * 2 + 1))Have damage in the conditions, but no lengths left -> 0")
            return []
        }
        if firstLength == 1 {
            // Entirely consumed. Need the next condition to able to be mapped to operational otherwise it'd be merged
            let remaining = conditions.dropFirst()
            guard let separator = remaining.first else {
                // No trailing separator, but the end of the conditions is an implicit separator
                return [prefix + String(Condition.damaged.rawValue)]
            }
            guard separator != .damaged else {
                print("\(indent(prefix.count * 2 + 1))XXX damage length of 1, but next is \(separator) -> 0")
                return []
            }
            return pack(length: length, prefix: prefix + String(Condition.damaged.rawValue) + String(Condition.operational.rawValue), conditions: remaining.dropFirst(), damagedLengths: damagedLengths.dropFirst())
        } else {
            // Used up one unit of the first damaged length
            return pack(length: length, prefix: prefix + String(Condition.damaged.rawValue), conditions: conditions.dropFirst(), damagedLengths: [firstLength - 1] + damagedLengths.dropFirst())
        }
    case .unknown:
        // Can either assume this spot is damaged or not
        let damagedCount = pack(length: length, prefix: prefix, conditions: [.damaged] + conditions.dropFirst(), damagedLengths: damagedLengths)
        let undamagedCount = pack(length: length, prefix: prefix, conditions: [.operational] + conditions.dropFirst(), damagedLengths: damagedLengths)

        return undamagedCount + damagedCount
    }

}

var result = 0

for line in lines {
    let components = line.split(separator: " ")
    let conditions = components[0].map { Condition(rawValue: $0)! }
    let damagedLengths = String(components[1]).numbers(separatedBy: CharacterSet(charactersIn: ","))

    let options = pack(length: conditions.count, prefix: "", conditions: conditions[...], damagedLengths: damagedLengths[...])
    print("~~~~ \(line) \(options.count):")
    options.forEach { print($0) }
    print("~~~~")

    result += options.count
}

print("\(result)")
// 114033 too high with case that failed on test input
