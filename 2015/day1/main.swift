//
//  main.swift
//  day1
//
//  Created by Timothy Wood on 12/2/24.
//

import Foundation

let input = Input.input()

func change(_ ch: String.Element) -> Int {
    switch ch {
    case "(":
        return 1
    case ")":
        return -1
    case "\n":
        return 0
    default:
        fatalError()
    }
}

do {
    let total = input.reduce(0, {previous, elt in
        return previous + change(elt)
    })
    print("\(total)")
    assert(total == 138)
}

do {
    var index = 0
    var floor = 0

    for ch in input {
        floor += change(ch)
        if floor == -1 {
            let result = index + 1
            print("\(result)")
            assert(result == 1771)
            exit(0) // part 2!
        }
        index += 1
    }
    fatalError()
}

