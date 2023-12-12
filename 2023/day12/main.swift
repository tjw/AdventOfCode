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

    if damagedLengths.isEmpty {
        // If there are no more known damages, then we need all remaining conditions to be able map to operational.
        let result = conditions.allSatisfy({ $0 != .damaged }) ? 1 : 0
        print("\(indent(level + 1))XXX no more damage expected -> \(result)")
        return result
    }
    if conditions.isEmpty {
        // If there are no further conditions, we have to be out of damages
        let result = damagedLengths.isEmpty ? 1 : 0
        print("\(indent(level + 1))XXX out of conditions, should be no more damage -> \(result)")
        return result
    }

    switch conditions.first! {
    case .operational:
        // Can't pack any damaged length into an operational spot
        return pack(level: level + 1, conditions: conditions.dropFirst(), damagedLengths: damagedLengths)
    case .damaged:
        // If this is guaranteed damaged, need the first damage range to use it up
        let firstLength = damagedLengths.first!
        if firstLength == 1 {
            // Entirely consumed. Need the next condition to able to be mapped to operational otherwise it'd be merged
            let remaining = conditions.dropFirst()
            guard remaining.first != .damaged else {
                print("\(indent(level + 1))XXX damage length of 1, but next is \(remaining.first!) -> 0")
                return 0
            }
            return pack(level: level + 1, conditions: remaining.dropFirst(), damagedLengths: damagedLengths.dropFirst())
        } else {
            return pack(level: level + 1, conditions: conditions.dropFirst(), damagedLengths: [firstLength - 1] + damagedLengths.dropFirst())
        }
    case .unknown:
        // Can either assume this spot is undamaged or it is.
        let undamagedCount = pack(level: level + 1, conditions: [.operational] + conditions.dropFirst(), damagedLengths: damagedLengths)
        let damagedCount = pack(level: level + 1, conditions: [.damaged] + conditions.dropFirst(), damagedLengths: damagedLengths)

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
