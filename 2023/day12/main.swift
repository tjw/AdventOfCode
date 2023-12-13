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

    //print("\(prefix) -- \((conditions.map { String($0.rawValue) }).joined()) \(damagedLengths)")

    if conditions.isEmpty {
        if damagedLengths.isEmpty {
            //print("\(indent(prefix.count * 2 + 1))at end -> 1")
            return [prefix]
        } else {
            //print("\(indent(prefix.count * 2 + 1))expecting more damage -> 0")
            return []
        }
    }

    let totalDamageLeft = damagedLengths.reduce(0, { $0 + $1 })
    let possibleDamageLeft = conditions.reduce(0, { $0 + ($1 == .operational ? 0 : 1) })
    // maybe count the guaranteed damage left and use it as a lower bound to continue
    if totalDamageLeft > possibleDamageLeft {
        return []
    }

    let current = conditions.first!
    switch current {
    case .operational:
        // Can't pack any damaged length into an operational spot
        return pack(length: length, prefix: prefix + String(current.rawValue), conditions: conditions.dropFirst(), damagedLengths: damagedLengths)
    case .damaged:
        // If we have a definitely (or provisionally assumed) damaged, then we need to have a string of damage matching the given length here and then a separator or the end of the conditions
        guard let firstLength = damagedLengths.first else {
            //print("\(indent(prefix.count * 2 + 1))Have damage in the conditions, but no lengths left -> 0")
            return []
        }

        var updatedPrefix = prefix + String(Condition.damaged.rawValue)
        var remainingConditions = conditions.dropFirst() // first one is the one we just hit
        var remainingLength = firstLength - 1

        // Consume any remaining required damage length
        while remainingLength > 0 {
            guard let next = remainingConditions.first else {
                //print("\(indent(prefix.count * 2 + 1))XXX remaining damage length of \(remainingLength), but ran out of conditions")
                return []
            }
            guard next != .operational else {
                //print("\(indent(prefix.count * 2 + 1))XXX remaining damage length of \(remainingLength), but next is \(next)")
                return []
            }

            updatedPrefix = updatedPrefix + String(Condition.damaged.rawValue)
            remainingConditions = remainingConditions.dropFirst()
            remainingLength -= 1
        }

        // Now, need a separator or the end of conditions
        if let separator = remainingConditions.first {
            if separator != .damaged {
                updatedPrefix = updatedPrefix + String(Condition.operational.rawValue)
                remainingConditions = remainingConditions.dropFirst()

                return pack(length: length, prefix: updatedPrefix, conditions: remainingConditions, damagedLengths: damagedLengths.dropFirst())
            } else {
                //print("\(indent(prefix.count * 2 + 1))XXX need a separator after damage but next is \(separator) -> 0")
                return []
            }
        } else {
            // No trailing separator, but the end of the conditions is an implicit separator. Recurse to handle the case there are more damaged lengths
            return pack(length: length, prefix: updatedPrefix, conditions: remainingConditions, damagedLengths: damagedLengths.dropFirst())
        }
    case .unknown:
        // Can either assume this spot is damaged or not
        let damagedCount = pack(length: length, prefix: prefix, conditions: [.damaged] + conditions.dropFirst(), damagedLengths: damagedLengths)
        let undamagedCount = pack(length: length, prefix: prefix, conditions: [.operational] + conditions.dropFirst(), damagedLengths: damagedLengths)

        return undamagedCount + damagedCount
    }

}

do {
    var result = 0

    for line in lines {
        let components = line.split(separator: " ")
        let conditions = components[0].map { Condition(rawValue: $0)! }
        let damagedLengths = String(components[1]).numbers(separatedBy: CharacterSet(charactersIn: ","))

        let options = pack(length: conditions.count, prefix: "", conditions: conditions[...], damagedLengths: damagedLengths[...])
        print("~~~~ \(line) \(options.count):")
        //    options.forEach { print($0) }
        //    print("~~~~")

        result += options.count
    }

    print("\(result)")
    //assert(result == 7705) // part 1
}

do {
    var result = 0

    for line in lines {
        let components = line.split(separator: " ")
        let conditions = components[0].map { Condition(rawValue: $0)! }
        let damagedLengths = String(components[1]).numbers(separatedBy: CharacterSet(charactersIn: ","))

        let repeatedConditions = conditions + [.unknown] + conditions + [.unknown] + conditions + [.unknown] + conditions + [.unknown] + conditions
        let repeatedLengths = damagedLengths + damagedLengths + damagedLengths + damagedLengths + damagedLengths

        let options = pack(length: repeatedConditions.count, prefix: "", conditions: repeatedConditions[...], damagedLengths: repeatedLengths[...])
        print("~~~~ \(line) \(options.count):")
        //    options.forEach { print($0) }
        //    print("~~~~")

        result += options.count
    }

    print("\(result)")
}
