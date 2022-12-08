//
//  main.swift
//  day2
//
//  Created by Timothy Wood on 11/26/22.
//

import Foundation

enum Direction: String {
    case forward
    case down
    case up
}

do {
    var depth = 0
    var position = 0

    for line in Input.lines {
        let components = line.split(separator: " ")
        let direction = Direction(rawValue: String(components[0]))!
        let offset = Int(components[1])!

        switch direction {
        case .forward:
            position += offset
        case .down:
            depth += offset
        case .up:
            depth -= offset
            assert(depth >= 0)
        }
    }

    print("\(position * depth)")
    assert(position * depth == 2120749)
}

// part 2
do {
    var depth = 0
    var position = 0
    var aim = 0

    for line in Input.lines {
        let components = line.split(separator: " ")
        let direction = Direction(rawValue: String(components[0]))!
        let offset = Int(components[1])!

        switch direction {
        case .forward:
            position += offset
            depth += aim * offset
            assert(depth >= 0)
        case .down:
            aim += offset
        case .up:
            aim -= offset
        }
    }

    print("\(position * depth)")
    assert(position * depth == 2138382217)
}

