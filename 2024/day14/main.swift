//
//  main.swift
//  day14
//
//  Created by Timothy Wood on 12/13/24.
//

import Foundation

let regex = /p=([0-9]+),([0-9]+) v=([-0-9]+),([-0-9]+)/

class Robot {
    var position: Location2D
    let velocity: Location2D

    init(line: String) {
        let match = try! regex.wholeMatch(in: line)!
        position = Location2D(x: Int(match.1)!, y: Int(match.2)!)
        velocity = Location2D(x: Int(match.3)!, y: Int(match.4)!)
    }

    func step(width: Int, height: Int) {
        position += velocity

        while position.x < 0 {
            position.x += width
        }
        while position.x >= width {
            position.x -= width
        }

        while position.y < 0 {
            position.y += height
        }
        while position.y >= height {
            position.y -= height
        }
    }
}

do {
    let robots = Input.lines().map { Robot(line: $0) }
    let width = 101
    let height = 103
    let midX = width/2
    let midY = height/2

    var quads = Array(repeating: 0, count: 4)
    let map = GridMap(element: 0, width: width, height: height)

    for robot in robots {
        for second in 1...100 {
            robot.step(width: width, height: height)
            //print("second \(second): position: \(robot.position)")
        }

        var quad = 0
        let position = robot.position

        map[position]! = map[position]! + 1

        if position.x == midX || position.y == midY {
            // skip
        } else {
            if position.x > midX {
                quad += 2
            }
            if position.y > midY {
                quad += 1
            }

            quads[quad] += 1
        }
    }

    print("map:")
    (0..<height).forEach { y in
        print(map.row(y: y).map { $0 == 0 ? "." : String($0) }.joined())
    }
    print("quads \(quads)")

    let result = quads.reduce(1, { $0 * $1 })
    print("\(result)")
    // 25404256958945004 not the answer
}

do {
    let robots = Input.lines().map { Robot(line: $0) }
    let width = 101
    let height = 103

    for second in 1...1000000 {
        let map = GridMap(element: 0, width: width, height: height)

        for robot in robots {
            robot.step(width: width, height: height)
            //print("second \(second): position: \(robot.position)")

            let position = robot.position

            map[position]! = map[position]! + 1
        }

        // Don't know what the picture will look like, but it should have a row that is "mostly" more filled (non-zero) than normal, as the tree gets wider.

        var counts = Array(repeating: 0, count: height)
        (0..<height).forEach { y in
            counts[y] = map.row(y: y).count(where: { $0 > 0 })
        }

        let shouldPrint = counts.contains(where: { $0 > 30} )

        if shouldPrint {
            print("\nSecond \(second) map:")
            (0..<height).forEach { y in
                print(map.row(y: y).map { $0 == 0 ? "." : String($0) }.joined())
            }
        }

    }
}
