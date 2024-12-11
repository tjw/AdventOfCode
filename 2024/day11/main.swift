//
//  main.swift
//  day11
//
//  Created by Timothy Wood on 12/10/24.
//

import Foundation

//do {
//    var stones = Input.input().numbers()
//    print("initial \(stones)")
//
//    for blink in 1..<26 {
//        let next = stones.flatMap { (stone: Int) -> [Int] in
//            if stone == 0 {
//                return [1]
//            }
//            let str = "\(stone)"
//            if str.count % 2 == 0 {
//                let split = str.index(str.startIndex, offsetBy: str.count / 2)
//                let left = str.prefix(upTo: split)
//                let right = str.suffix(from: split)
//                //print("\(stone) -> \(left) and \(right)")
//                return [Int(left)!, Int(right)!]
//            }
//            return [stone * 2024]
//        }
//
//        stones = next
//        print("blink \(blink) count \(stones.count)")
//        //print("blink \(blink) -> \(stones)")
//    }
//
//    print("count \(stones.count)")
////    assert(stones.count == 186203)
//}

// Iterations start getting slow when there are 100s of thousands of stones. All the stones can be computed independenly though, so try doing one at a time
do {
    let stones = Input.input().numbers()
    print("initial \(stones)")

    var endBlinks = [[Int]]()

    for stone in stones {
        print("*** stone \(stone)")
        var current = [stone]

        for blink in 1..<76 {
            var next = [Int]()
            for c in current {
                if c == 0 {
                    next.append(1)
                    continue
                }
                let str = "\(c)"
                if str.count % 2 == 0 {
                    let split = str.index(str.startIndex, offsetBy: str.count / 2)
                    let left = str.prefix(upTo: split)
                    let right = str.suffix(from: split)
                    //print("\(c) -> \(left) and \(right)")
                    next.append(Int(left)!)
                    next.append(Int(right)!)
                    continue
                }
                next.append(c * 2024)
                continue
            }

            current = next
            print("blink \(blink) count \(current.count)")
            //print("blink \(blink) -> \(current)")
        }

        endBlinks.append(current)
    }

    let endBlink = endBlinks.flatMap { $0 }
    print("count \(endBlink.count)")
}
