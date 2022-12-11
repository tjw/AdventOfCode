//
//  main.swift
//  day10
//
//  Created by Timothy Wood on 12/9/22.
//

import Foundation

// addv 2 cycles to complete. After 2 cyles X is X += v (can be negative)
// noop takes 1 cycle to complete
// A cycle starts on the given instruction so
// noop
// starts on the leading side and completes on the trailing side
// instructions are synchronous, so an addv doesn't start until all the previous instructions have committed

let lines = Input.lines()

do {
    var X = 1
    var cycle = 0
    var strength = 1

    var totalStrength = 0

    func nextCycle() {
        cycle += 1

        if cycle == 20 || (cycle - 20) % 40 == 0 {
            strength = cycle * X
            totalStrength += strength
        }
    }
    lines.forEach { line in
        let components = line.split(separator: " ")
        if components[0] == "noop" {
            nextCycle()
        } else if components[0] == "addx" {
            nextCycle()
            nextCycle()
            X += Int(components[1])!
        } else {
            fatalError()
        }
    }

    print("\(totalStrength)")
    assert(totalStrength == 15880)
}

do {
    var X = 1
    var cycle = 0

    var previousScanlines = [String]()
    var currentScanline = ""

    func nextCycle() {
        // Draw pixel
        let pixelX = cycle % 40
        if abs(pixelX - X) <= 1 {
            currentScanline.append("#") // Lit
        } else {
            currentScanline.append(".") // Dark
        }

        cycle += 1
        if cycle % 40 == 0 {
            previousScanlines.append(currentScanline)
            currentScanline = ""
        }
    }

    lines.forEach { line in
        let components = line.split(separator: " ")
        if components[0] == "noop" {
            nextCycle()
        } else if components[0] == "addx" {
            nextCycle()
            nextCycle()
            X += Int(components[1])!
        } else {
            fatalError()
        }
    }

    if !currentScanline.isEmpty {
        previousScanlines.append(currentScanline)
    }

    previousScanlines.forEach { print($0) }

//    let expected = """
//###..#.....##..####.#..#..##..####..##..
//#..#.#....#..#.#....#.#..#..#....#.#..#.
//#..#.#....#....###..##...#..#...#..#....
//###..#....#.##.#....#.#..####..#...#.##.
//#....#....#..#.#....#.#..#..#.#....#..#.
//#....####..###.#....#..#.#..#.####..###.
//"""
//    assert(previousScanlines.joined() + "\n" == expected)
}
