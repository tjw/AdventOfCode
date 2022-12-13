//
//  main.swift
//  day13
//
//  Created by Timothy Wood on 12/12/22.
//

import Foundation

do {
    func correctlyOrdered(left left_: ArraySlice<Any>, right right_: ArraySlice<Any>) -> Bool {
        print("####")
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
                }
            }

            if leftNext is Array<Any> || rightNext is Array<Any> {
                let leftSlice = (leftNext as? [Any] ?? [leftNext as! Int])[...]
                let rightSlice = (rightNext as? [Any] ?? [rightNext as! Int])[...]
                return correctlyOrdered(left: leftSlice, right: rightSlice)
            }
        }

        if left.isEmpty {
            return true
        }

        return false
    }


    var outOfOrder = 0
    var remaining = input[0..<input.count]
    print("\(type(of: remaining))")
    while !remaining.isEmpty {
        // Top level is always an array
        let left = remaining.first! as! [Any]
        remaining = remaining.dropFirst()

        let right = remaining.first! as! [Any]
        remaining = remaining.dropFirst()

        if !correctlyOrdered(left: left[...], right: right[...]) {
            outOfOrder += 1
        }
    }

    print("\(outOfOrder)")
    // 44 incorrect
}

