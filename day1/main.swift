//
//  main.swift
//  day1
//
//  Created by Timothy Wood on 11/25/22.
//

import Foundation

let lines = Input.lines

do {
    var deeper = 0
    var previous: Int? = nil

    for line in lines {
        let current = Int(line)!
        if let p = previous {
            if current > p {
                deeper += 1
            }
        }
        previous = current
    }


    print("\(deeper)")
    assert(deeper == 1759)
}

// windowed
do {
    var deeper = 0
    var window: [Int] = []
    var previous: Int?

    for line in lines {
        let value = Int(line)!

        window.append(value)
        if window.count > 3 {
            window.removeFirst()
        }

        if window.count == 3 {
            let current = window.reduce(0, +)
            if let p = previous {
                if current > p {
                    deeper += 1
                }
            }
            previous = current
        }
    }

    print("\(deeper)")
    assert(deeper == 1805)
}

