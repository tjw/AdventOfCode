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

func pack(conditions: Array<Condition>.SubSequence, damagedLengths: Array<Int>.SubSequence) -> Int {
    print("\((conditions.map { String($0.rawValue) }).joined()) \(damagedLengths)")

    if damagedLengths.isEmpty {
        // If there are no more known damages, then we need all remaining conditions to be able map to operational.
        let result = conditions.allSatisfy({ $0 != .damaged }) ? 1 : 0
        print("  no more damage expected -> \(result)")
        return result
    }
    if conditions.isEmpty {
        // If there are no further conditions, we have to be out of damages
        let result = damagedLengths.isEmpty ? 1 : 0
        print("  out of conditions, should be no more damage -> \(result)")
        return result
    }

    switch conditions.first! {
    case .operational:
        // Can't pack any damaged length into an operational spot
        return pack(conditions: conditions.dropFirst(), damagedLengths: damagedLengths)
    case .damaged:
        // If this is guaranteed damaged, need the first damage range to use it up
        guard let firstLength = damagedLengths.first else {
            print("  first is damaged, but no lengths left -> 0")
            return 0
        }
        if firstLength == 1 {
            // Entirely consumed. Need the next condition to able to be mapped to operational otherwise it'd be merged
            let remaining = conditions.dropFirst()
            guard remaining.first != .damaged else {
                print("  XXX damage length of 1, but next is \(remaining.first!) -> 0")
                return 0
            }
            return pack(conditions: remaining.dropFirst(), damagedLengths: damagedLengths.dropFirst())
        } else {
            return pack(conditions: conditions.dropFirst(), damagedLengths: [firstLength - 1] + damagedLengths.dropFirst())
        }
    case .unknown:
        // Can either assume this spot is undamaged or it is.

        let undamagedCount = pack(conditions: [.operational] + conditions.dropFirst(), damagedLengths: damagedLengths)
        let damagedCount = pack(conditions: [.damaged] + conditions.dropFirst(), damagedLengths: damagedLengths)

        return undamagedCount + damagedCount
        
        /*
        // Assume it is undamaged. One condition is used, and no lengths.
        let undamagedCount = pack(conditions: conditions.dropFirst(), damagedLengths: damagedLengths)

        // If we assume this spot is going to use up the damaged length, we need that many unknowns or damages in a row, followed by either an operational (or an unknown we'll need to map to operational)
        var damagedLength = damagedLengths.first!
        var remainingConditions = conditions

        while damagedLength > 0 {
            guard let next = remainingConditions.first else {
                break
            }
            if next == .operational {
                // Can't map this much damage
                return undamagedCount
            }
            damagedLength -= 1
            remainingConditions = remainingConditions.dropFirst()
        }

        if remainingConditions.first == .damaged {
            // This would have been merged into the given length, so this doesn't work
            return undamagedCount
        }

        // Drop off the operational or unknown sequence breaker
        let damagedCount = pack(conditions: remainingConditions.dropFirst(), damagedLengths: damagedLengths.dropFirst())
        return undamagedCount + damagedCount
         */
    }

}

var result = 0

for line in lines {
    let components = line.split(separator: " ")
    let conditions = components[0].map { Condition(rawValue: $0)! }
    let damagedLengths = String(components[1]).numbers(separatedBy: CharacterSet(charactersIn: ","))

    let count = pack(conditions: conditions[...], damagedLengths: damagedLengths[...])
    print("~~~~ \(line) -> \(count)")
    result += count
}

print("\(result)")
