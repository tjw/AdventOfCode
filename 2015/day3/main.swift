//
//  main.swift
//  day3
//
//  Created by Timothy Wood on 12/3/24.
//

import Foundation

let input = Input.input().trimmingCharacters(in: .whitespacesAndNewlines)

do {
    var location = Location2D(x: 0, y: 0)

    let map = HashMap2D<Int>(defaultElement: 0)
    map[location] = 1

    input.forEach { ch in
        let direction: Location2D =
        switch ch {
        case "<": .left
        case ">": .right
        case "^": .up
        case "v": .down
        default:
            fatalError()
        }

        location += direction
        map[location] += 1
    }

    var total = 0
    map.forEach { _, count in
        if count > 0 {
            total += 1
        }
    }
    print("\(total)")
}

do {
    var locationA = Location2D(x: 0, y: 0)
    var locationB = Location2D(x: 0, y: 0)

    let map = HashMap2D<Int>(defaultElement: 0)
    map[locationA] = 2 // One for each

    var movingA = true

    input.forEach { ch in
        let direction: Location2D =
        switch ch {
        case "<": .left
        case ">": .right
        case "^": .up
        case "v": .down
        default:
            fatalError()
        }

        if movingA {
            locationA += direction
            map[locationA] += 1
        } else {
            locationB += direction
            map[locationB] += 1
        }
        movingA = !movingA
    }

    var total = 0
    map.forEach { _, count in
        if count > 0 {
            total += 1
        }
    }
    print("\(total)")
}
