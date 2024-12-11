//
//  main.swift
//  day11
//
//  Created by Timothy Wood on 12/10/24.
//

import Foundation

do {
    var stones = Input.input().numbers()
    print("initial \(stones)")

    for blink in 1..<26 {
        let next = stones.flatMap { (stone: Int) -> [Int] in
            if stone == 0 {
                return [1]
            }
            let str = "\(stone)"
            if str.count % 2 == 0 {
                let split = str.index(str.startIndex, offsetBy: str.count / 2)
                let left = str.prefix(upTo: split)
                let right = str.suffix(from: split)
                //print("\(stone) -> \(left) and \(right)")
                return [Int(left)!, Int(right)!]
            }
            return [stone * 2024]
        }

        stones = next
        print("blink \(blink) count \(stones.count)")
        //print("blink \(blink) -> \(stones)")
    }

    print("count \(stones.count)")
    assert(stones.count == 186203)
}

do {
    // Stones can be computed independently (there are no rules that take into account more than one stone). Trying to iteratively compute the complete set of stones produces an impractally large array on each "blink" loop. Instead we can observe that we have rules that make stone values larger and lower and many values will computed over and over, so this is ripe for memoizing the results.

    // Start with a class for representing the question we are trying to resolve. Given a particular Stone value, what is its representation at a given number of blinks?
    class Stone : Hashable, CustomStringConvertible {

        // For any given input of a Stone with blinks > 0, there is an array of computed Stones
        static var memos = [Stone:Int]()

        let value: Int
        let blinks: Int // The number of blinks remaining

        init(value: Int, blinks: Int) {
            self.value = value
            self.blinks = blinks
        }

        var description: String {
            return "{value: \(value), blinks: \(blinks)}"
        }

        static func == (lhs: Stone, rhs: Stone) -> Bool {
            return lhs.value == rhs.value && lhs.blinks == rhs.blinks
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(value)
            hasher.combine(blinks)
        }

        // Could maybe combine these to produce a tuple, but often the power of 10 won't be needed
        func digitCount(_ n: Int) -> Int {
            var x = n
            var digits = 0
            while x > 0 {
                digits += 1
                x /= 10
            }
            return digits
        }
        func pow10(_ n: Int) -> Int {
            var x = 1
            (0..<n).forEach { _ in
                x = x*10
            }
            return x
        }

        var count: Int {
            // Early out if we have already computed our count, or if we are a base case
            if let count = Self.memos[self] {
                return count
            }
            if blinks == 0 {
                return 1
            }

            // Look for previously memoized values for the new Stones evolved from this one or build them.
            if value == 0 {
                let proto = Stone(value: 1, blinks: blinks - 1)
                if let existing = Self.memos[proto] {
                    Self.memos[self] = existing
                    return existing
                } else {
                    return proto.count // Will memoize itself
                }
            }

            let digits = digitCount(value)
            if digits % 2 == 0 {
                let divisor = pow10(digits/2)
                let left = Stone(value: value / divisor, blinks: blinks - 1)
                let right = Stone(value: value % divisor, blinks: blinks - 1)
                //print("\(c) -> \(left) and \(right)")

                let leftCount = left.count
                let rightCount = right.count

                Self.memos[self] = leftCount + rightCount
                return leftCount + rightCount
            }

            let proto = Stone(value: value * 2024, blinks: blinks - 1)
            let count = proto.count
            Self.memos[self] = count
            return count
        }
    }

    let blinks = 75
    let stones = Input.input().numbers().map { Stone(value: $0, blinks: blinks)}
    print("initial \(stones)")

    let result = stones.reduce(0, { $0 + $1.count })
    print("\(result)")
    assert(result == 221291560078593)
}
