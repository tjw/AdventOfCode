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

var hasSolution = [String:Bool]()

func checkForSolution(_ string: String) -> Bool {
    if let value = hasSolution[string] {
        return value
    }
    for towel in availableTowels {
        if string.hasPrefix(towel) {
            if string == towel {
                //print("string \(string) -- true")
                hasSolution[string] = true
                return true
            } else {
                let remainder = string.trimmingPrefix(towel)
                if checkForSolution(String(remainder)) {
                    //print("string \(string) -- true")
                    hasSolution[string] = true
                    return true
                }
            }
        }
    }
    //print("string \(string) -- false")
    hasSolution[string] = false
    return false
}

let count = patterns.count {
    let value = checkForSolution($0)
    print("# \($0) -- \(value)")
    return value
}
print("\(count)")
assert(count == 251)

