//
//  main.swift
//  day8
//
//  Created by Timothy Wood on 12/4/24.
//

import Foundation

let lines = Input.lines()

do {
    var codeLength = 0
    var stringLength = 0

    lines.forEach { line in
        codeLength += line.count

        var remaining = line[...]

        // These don't count for the string length
        assert(remaining.first == "\"")
        assert(remaining.last == "\"")
        remaining = remaining.dropFirst().dropLast()

        while !remaining.isEmpty {
            if remaining.hasPrefix("\\") {
                remaining = remaining.dropFirst()

                switch remaining.first {
                case "x":
                    remaining = remaining.dropFirst(3) // the x and two hex digits
                    stringLength += 1
                case "\"", "\\":
                    remaining = remaining.dropFirst() // the quoted character
                    stringLength += 1
                default:
                    fatalError()
                }
            } else {
                remaining = remaining.dropFirst()
                stringLength += 1
            }
        }
    }

    let result = codeLength - stringLength
    print("\(result)")
    assert(result == 1342)
}

do {
    var codeLength = 0
    var stringLength = 0

    lines.forEach { line in
        stringLength += line.count
        codeLength += 2 // start end end quotes

        var remaining = line[...]
        while !remaining.isEmpty {
            switch remaining.first {
            case "\"", "\\":
                codeLength += 2 // Character and an extra backslash
            default:
                codeLength += 1
            }

            remaining = remaining.dropFirst()
        }
    }

    let result = codeLength - stringLength
    print("\(result)")
    assert(result == 2074)
}
