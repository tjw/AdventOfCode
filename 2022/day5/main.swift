//
//  main.swift
//  day5
//
//  Created by Timothy Wood on 12/8/22.
//

import Foundation

typealias Stack = [String]

func printStacks(_ stacks: [Stack]) {
    stacks.enumerated().forEach { idx, stack in
        print("\(idx + 1): \(stack)")
    }
}

func parseStacks(_ lines: inout [String]) -> [Stack] {
    // TODO: Use Regex under Ventura?
    // The input is very organized...

    var stacks = [Stack]()

    while let line = lines.first {
        lines = Array(lines.dropFirst())

        if line.isEmpty { break } // newline before 'move' commands

        var remaining = Substring(line)
        var stackIndex = 0
        while !remaining.isEmpty {
            assert(remaining.first == " " || remaining.first == "[")
            remaining = remaining.dropFirst() // '['

            let crate = remaining.first!
            remaining = remaining.dropFirst(3) // 'X] '  TODO Will this handle the last crate which doesn't have a trailing newline?

            if crate == "1" { break } // pretty useless counter line

            if crate != " " {
                while stackIndex >= stacks.count {
                    stacks.append(Stack())
                }

                stacks[stackIndex].append(String(crate))
            }

            stackIndex += 1
        }
    }

    return stacks
}

func processMoves(stacks initialStacks: [Stack], moves: [String], allowMultiple: Bool) -> String {
    var stacks = initialStacks
    for line in lines {
        guard !line.isEmpty else { continue }
        guard line.hasPrefix("move") else { fatalError() }

        let components = line.split(separator: " ")
        let count = Int(components[1])!
        let source = Int(components[3])! - 1
        let destination = Int(components[5])! - 1

        if allowMultiple {
            let crates = stacks[source][0..<count]
            stacks[source] = Array(stacks[source].dropFirst(count))

            stacks[destination].insert(contentsOf: crates, at: 0)
        } else {
            (0..<count).forEach { _ in
                let crate = stacks[source].first!
                stacks[source] = Array(stacks[source].dropFirst())

                stacks[destination].insert(crate, at: 0)
            }
        }
    }

    return stacks.map { $0.first! }.joined()
}

var lines = Input.lines(includeEmpty: true)
let stacks = parseStacks(&lines)

do {
    let result = processMoves(stacks: stacks, moves: lines, allowMultiple: false)
    print("\(result)")
    assert(result == "RFFFWBPNS")
}

do {
    let result = processMoves(stacks: stacks, moves: lines, allowMultiple: true)
    print("\(result)")
    assert(result == "CQQBBJFCS")
}

