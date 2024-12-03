//
//  main.swift
//  day2
//
//  Created by Timothy Wood on 12/2/24.
//

import Foundation

let regex = /([0-9]+)x([0-9]+)x([0-9]+)/

struct Package {
    let a, b, c: Int

    init(_ line: String) {
        let match = line.firstMatch(of: regex)!
        a = Int(match.1)!
        b = Int(match.2)!
        c = Int(match.3)!
    }
}

let packages = Input.lines().map { Package($0) }

do {
    let total = packages.reduce(0, {previous, item in
        let side1 = item.a*item.b
        let side2 = item.b*item.c
        let side3 = item.c*item.a

        let smallest = min(side1, side2, side3)

        return previous + 2*side1 + 2*side2 + 2*side3 + smallest
    })

    print("\(total)")
    assert(total == 1588178)
}

do {
    let total = packages.reduce(0, { previous, item in
        let wrap = 2 * min(item.a + item.b, item.b + item.c, item.c + item.a)
        let bow = item.a * item.b * item.c
        return previous + wrap + bow
    })
    print("\(total)")
    assert(total == 3783758)
}
