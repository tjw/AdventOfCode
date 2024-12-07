//
//  main.swift
//  day7
//
//  Created by Timothy Wood on 12/6/24.
//

import Foundation

struct Item {
    let result: Int
    let inputs: [Int]
}

let items = Input.lines().map { line in
    let components = line.split(separator: ":")
    let result = Int(components[0])!
    let inputs = components[1].split(separator: " ").map{ Int($0)! }
    return Item(result: result, inputs: inputs)
}

do {
    var result = 0
    for item in items {

        // Given an item with say, 5 inputs, there are four slots between the numbers to insert either a + or a *. Assign + to 0 and * to 1
        for idx in 0..<(1 << item.inputs.count - 1) {
            var x = idx
            var total = item.inputs.first!
            for input in item.inputs.dropFirst() {
                if x & 0x1 == 0 {
                    total += input
                } else {
                    total *= input
                }
                x >>= 1
            }
            if total == item.result {
                result += total
                break // could be multiple ways to go
            }
        }

    }
//    print("\(result)")
//    assert(result == 28730327770375)
}

do {
    var result = 0

    func pow3ish(_ n: Int) -> Int {
        var result = 1
        (0..<n).forEach { _ in
            result *= 3
        }
        return result
    }

    func concat(_ a: Int, _ b: Int) -> Int {
        // 123 || 456 -> 123456
        var mult = 1
        while mult < b {
            mult *= 10
        }
        return a * mult + b
    }

    for item in items {
        // Given an item with say, 5 inputs, there are four slots between the numbers to insert either a + or a *. Assign + to 0 and * to 1
        let upper = pow3ish(item.inputs.count)
        print("item \(item.result) \(item.inputs), upper \(upper)")
        for idx in 0..<upper {
            var x = idx
            var total = item.inputs.first!
            for input in item.inputs.dropFirst() {
                switch x % 3 {
                case 0:
                    total += input
                case 1:
                    total *= input
                case 2:
                    total = concat(total, input)
                default:
                    fatalError()
                }
                x /= 3
            }
            if total == item.result {
                result += total
                print("  match on \(idx)!")
                break // could be multiple ways to go
            }
        }

    }
    print("\(result)")
    // 297914586446459 is too low
    // 424261660171557 too low
}
