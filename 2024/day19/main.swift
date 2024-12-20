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

do {
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
        // print("# \($0) -- \(value)")
        return value
    }
    print("\(count)")
    assert(count == 251)
}

do {
    var solutionCount = [String:Int]()

    func countSolutions(_ string: String) -> Int {
        if let count = solutionCount[string] {
            return count
        }

        var count = 0

        for towel in availableTowels {
            guard string.hasPrefix(towel) else { continue }

            if string == towel {
                count += 1
            } else {
                let remainder = string.trimmingPrefix(towel)
                count += countSolutions(String(remainder))
            }
        }

        //print("memo \(string) -- \(count)")
        solutionCount[string] = count
        return count
    }

    let total = patterns.reduce(0, { $0 + countSolutions($1) })
    print("\(total)")
    assert(total == 616957151871345)
}


