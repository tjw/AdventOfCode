//
//  main.swift
//  day3
//
//  Created by Timothy Wood on 12/2/24.
//

import Foundation

let input = Input.input()

do {
    let regex = /mul\(([0-9]+),([0-9]+)\)/
    let total = input.matches(of: regex).reduce(0, { previous, match in
        previous + Int(match.1)! * Int(match.2)!
    })
    print("\(total)")
    assert(total == 174103751)
}

do {
    let regex = /mul\(([0-9]+),([0-9]+)\)|do\(\)|don't\(\)/
    var enabled = 1
    let total = input.matches(of: regex).reduce(0, { previous, match in
        if match.0 == "do()" {
            enabled = 1
            return previous
        } else if match.0 == "don't()" {
            enabled = 0
            return previous
        } else {
            return previous + enabled * Int(match.1!)! * Int(match.2!)!
        }
    })
    print("\(total)")
    assert(total == 100411201)
}
