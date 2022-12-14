//
//  main.swift
//  day13
//
//  Created by Timothy Wood on 12/12/22.
//

import Foundation

var testInputs: [Any] = [
    [1,1,3,1,1],
    [1,1,5,1,1],

    [[1],[2,3,4]],
    [[1],4],

    [9],
    [[8,7,6]],

    [[4,4],4,4],
    [[4,4],4,4,4],

    [7,7,7,7],
    [7,7,7],

    [],
    [3],

    [[[]]],
    [[]],

    [1,[2,[3,[4,[5,6,7]]]],8,9],
    [1,[2,[3,[4,[5,6,0]]]],8,9],
]

func correctlyOrdered(left left_: ArraySlice<Any>, right right_: ArraySlice<Any>) -> Bool? {
    var left = left_
    var right = right_

    while !left.isEmpty && !right.isEmpty {
        let leftNext = left.first!; left = left.dropFirst()
        let rightNext = right.first!; right = right.dropFirst()

        print("leftNext \(leftNext)")
        print("rightNext \(rightNext)")

        if let leftInt = leftNext as? Int, let rightInt = rightNext as? Int {
            if leftInt < rightInt {
                return true
            } else if leftInt > rightInt {
                return false
            }
        } else if leftNext is Array<Any> || rightNext is Array<Any> {
            let leftSlice = (leftNext as? [Any] ?? [leftNext as! Int])[...]
            let rightSlice = (rightNext as? [Any] ?? [rightNext as! Int])[...]
            if let result =  correctlyOrdered(left: leftSlice, right: rightSlice) {
                return result
            }
        } else {
            fatalError()
        }
    }

    if left.isEmpty && right.isEmpty {
        return nil
    }
    if left.isEmpty {
        return true
    } else if right.isEmpty {
        return false
    }

    return true
}

do {
    var inOrderSum = 0
    var pairIndex = 1
    var remaining = input[0..<input.count]

    while !remaining.isEmpty {
        // Top level is always an array
        let left = remaining.first! as! [Any]
        remaining = remaining.dropFirst()

        let right = remaining.first! as! [Any]
        remaining = remaining.dropFirst()

        print("####")
        print("left \(left)")
        print("right \(right)")

        if let result = correctlyOrdered(left: left[...], right: right[...]) {
            if result {
                print("correct \(pairIndex)")
                inOrderSum += pairIndex
            } else {
                print("wrong")
            }
        } else {
            print("unknown")
        }

        pairIndex += 1
    }

    print("\(inOrderSum)")
    assert(inOrderSum == 5659)
}

