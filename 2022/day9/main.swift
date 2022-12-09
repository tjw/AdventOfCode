//
//  main.swift
//  day9
//
//  Created by Timothy Wood on 12/9/22.
//

import Foundation

struct Location : Hashable {
    let x: Int
    let y: Int

    static func +(left: Location, right: Location) -> Location {
        return Location(x: left.x + right.x, y: left.y + right.y)
    }
    static func -(left: Location, right: Location) -> Location {
        return Location(x: left.x - right.x, y: left.y - right.y)
    }
    static func +=(left: inout Location, right: Location) {
        left = Location(x: left.x + right.x, y: left.y + right.y)
    }

    static var left = Location(x: -1, y: 0)
    static var right = Location(x: 1, y: 0)
    static var up = Location(x: 0, y: 1)
    static var down = Location(x: 0, y: -1)
}

func touching(head: Location, tail: Location) -> Bool {
    let delta = head - tail
    return abs(delta.x) <= 1 && abs(delta.y) <= 1
}

func delta(head: Int, tail: Int) -> Int {
    if head > tail {
        return 1
    }
    if head < tail {
        return -1
    }
    return 0
}

let lines = Input.lines()

func process(count: Int) -> Int {
    var knots = Array(repeating: Location(x: 0, y: 0), count: count)
    var visited = Set<Location>([knots.last!])

    func move(direction: Location, steps: Int) {

        (0..<steps).forEach { _ in
            // Move the head
            knots[0] += direction

            // Consider each following knot until one doesn't need moving or we reach the end
            (0..<knots.count - 1).forEach { headIndex in
                let head = knots[headIndex]
                let tail = knots[headIndex + 1]

                if !touching(head: head, tail: tail) {
                    knots[headIndex + 1] += Location(x: delta(head: head.x, tail: tail.x), y: delta(head: head.y, tail: tail.y))
                }
            }

            visited.insert(knots.last!)
        }
    }

    lines.forEach { line in
        let components = line.split(separator: " ")
        let steps = Int(components[1])!
        switch components[0] {
        case "L": move(direction: .left, steps: steps)
        case "R": move(direction: .right, steps: steps)
        case "U": move(direction: .up, steps: steps)
        case "D": move(direction: .down, steps: steps)
        default: fatalError()
        }
    }

    return visited.count
}


do {
    let result = process(count: 2)
    print("\(result)")
    assert(result == 5619)
}
do {
    let result = process(count: 10)
    print("\(result)")
    assert(result == 2376)
}
