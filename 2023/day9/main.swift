//
//  main.swift
//  day9
//
//  Created by Timothy Wood on 12/7/23.
//

import Foundation

let lines = Input.lines()

do {
    var result = 0
    for line in lines {
        var sequences: [[Int]] = [line.numbers()]

        while true {
            var last = sequences.last![...]
            var next = [Int]()

            var a = last.first!
            last = last.dropFirst()

            while !last.isEmpty {
                let b = last.first!
                last = last.dropFirst()

                next.append(b - a)
                a = b
            }
            sequences.append(next)

            if next.allSatisfy({ $0 == 0 }) {
                break
            }
        }

        //sequences.forEach { print("\($0)")}

        let extrapolated = sequences.reversed().reduce(0, { $0 + $1.last! })
        //print("\(extrapolated)")
        result += extrapolated
    }
    print("\(result)")
}

do {
    var result = 0
    for line in lines {
        var sequences: [[Int]] = [line.numbers()]

        while true {
            var last = sequences.last![...]
            var next = [Int]()

            var a = last.first!
            last = last.dropFirst()

            while !last.isEmpty {
                let b = last.first!
                last = last.dropFirst()

                next.append(b - a)
                a = b
            }
            sequences.append(next)

            if next.allSatisfy({ $0 == 0 }) {
                break
            }
        }

        sequences.forEach { print("\($0)")}

        var extrapolated = 0
        for sequence in sequences.reversed() {
            extrapolated = sequence.first! - extrapolated
            //print("\(extrapolated)")
        }

        result += extrapolated
    }
    print("\(result)")
}
