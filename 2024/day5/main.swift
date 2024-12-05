//
//  main.swift
//  day5
//
//  Created by Timothy Wood on 12/4/24.
//

import Foundation

let sections = Input.sections()

// Key is the current page being printed, value is numbers not allowed to follow it
var rules = [Int:Set<Int>]()

for line in sections[0] {
    let items = line.split(separator: "|")
    assert(items.count == 2)

    let page = Int(items[1])!
    let mustBeBefore = Int(items[0])!

    var rule = rules[page] ?? Set()
    rule.insert(mustBeBefore)
    rules[page] = rule
}

func isUpdateAllowed(_ pages: [Int]) -> Bool {
    // As pages are printed, keep track of pages now disallowed *if* they are also printed
    var disallowed = Set<Int>()

    for page in pages {
        if disallowed.contains(page) {
            return false
        }
        disallowed.formUnion(rules[page] ?? [])
    }

    return true
}

do {
    var total = 0

    for updates in sections[1] {
        let pages = updates.numbers(separatedBy: ",")
        if isUpdateAllowed(pages) {
            let count = pages.count
            assert(count % 2 == 1) // assuming must be odd to have a well defined middle

            let middle = count/2
            total += pages[middle]
        }
    }
    print("\(total)")
    assert(total == 5651)
}

do {
    var total = 0

    for updates in sections[1] {
        let pages = updates.numbers(separatedBy: ",")
        if isUpdateAllowed(pages) {
            continue
        }

        // Resort based on the rules
        var updated = pages.sorted { a, b in
            // Compute a < b based on the rules
            let disallowed = rules[a] ?? []
            if disallowed.contains(b) {
                return false
            }
            return true
        }

        let count = updated.count
        let middle = count/2
        total += updated[middle]
    }
    print("\(total)")
    //assert(total == 5651)
}
