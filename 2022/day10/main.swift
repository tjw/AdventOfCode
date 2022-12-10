//
//  main.swift
//  day10
//
//  Created by Timothy Wood on 12/9/22.
//

import Foundation

let clockRate = 1 // ???
var X = 1

// addv 2 cycles to complete. After 2 cyles X is X += v (can be negative)
// noop takes 1 cycle to complete
// A cycle starts on the given instruction so
// noop
// starts on the leading side and completes on the trailing side
// instructions are synchronous, so an addv doesn't start until all the previous instructions have committed

var cycle = 0
var strength = 1

var totalStrength = 0

func nextCycle() {
    cycle += 1

    if cycle == 20 || (cycle - 20) % 40 == 0 {
        strength = cycle * X
        totalStrength += strength
    }

    print("cycle \(cycle), X \(X)")
}
for line in Input.lines() {
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
// 37 not right
