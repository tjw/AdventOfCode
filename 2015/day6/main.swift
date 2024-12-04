//
//  main.swift
//  day6
//
//  Created by Timothy Wood on 12/3/24.
//

import Foundation

enum Operation : String {
    case turnOn = "turn on"
    case turnOff = "turn off"
    case toggle = "toggle"
}
struct Instruction {
    let operation: Operation
    let bounds: Bounds2D
}

let regex = /(turn on|turn off|toggle) ([0-9]+),([0-9]+) through ([0-9]+),([0-9]+)/
let instructions = Input.lines().map { line in
    let match = line.wholeMatch(of: regex)!
    let operation = Operation(rawValue: String(match.1))!
    let startX = Int(match.2)!
    let startY = Int(match.3)!
    let endX = Int(match.4)!
    let endY = Int(match.5)!

    // Inputs are inclusie
    let width = endX - startX + 1
    let height = endY - startY + 1

    return Instruction(operation: operation, bounds: Bounds2D(x: startX, y: startY, width: width, height: height))
}

do {
    let map = GridMap(element: false, width: 1000, height: 1000)

    instructions.forEach { instruction in
        instruction.bounds.forEach { location in
            switch instruction.operation {
            case .turnOn:
                map[location] = true
            case .turnOff:
                map[location] = false
            case .toggle:
                map[location] = !(map[location]!)
            }
        }
    }

    let count = map.count(where: { $1 })
    print("\(count)")
    assert(count == 400410)
}

do {
    let map = GridMap(element: 0, width: 1000, height: 1000)

    instructions.forEach { instruction in
        instruction.bounds.forEach { location in
            switch instruction.operation {
            case .turnOn:
                map[location] = map[location]! + 1
            case .turnOff:
                map[location] = max(map[location]! - 1, 0)
            case .toggle:
                map[location] = map[location]! + 2
            }
        }
    }

    var total = 0
    map.forEach { _, brightness in
        total += brightness
    }
    print("\(total)")
    assert(total == 15343601)
}

