//
//  main.swift
//  day13
//
//  Created by Timothy Wood on 12/12/24.
//

import Foundation

// Button A: X+94, Y+34 Button B: X+22, Y+67 Prize: X=8400, Y=5400
let regex = /Button A: X\+([0-9]+), Y\+([0-9]+) Button B: X\+([0-9]+), Y\+([0-9]+) Prize: X=([0-9]+), Y=([0-9]+)/

struct Machine {
    let buttonA: Location2D
    let buttonB: Location2D
    let prize: Location2D

    init(line: String) {
        let match = line.wholeMatch(of: regex)!
        buttonA = Location2D(x: Int(match.1)!, y: Int(match.2)!)
        buttonB = Location2D(x: Int(match.3)!, y: Int(match.4)!)
        prize = Location2D(x: Int(match.5)!, y: Int(match.6)!)
    }
}

let costA = 3
let costB = 1

let machines = Input.sections().map { section in
    let line = section.joined(separator: " ")
    return Machine(line: line)
}
//print("machines \(machines)")

struct Move : Comparable {
    var pressesA: Int
    var pressesB: Int
    var location: Location2D

    var cost: Int {
        return pressesA * costA + pressesB * costB
    }
    static func < (lhs: Move, rhs: Move) -> Bool {
        return lhs.cost < rhs.cost
    }
}

// Using a heap expands too many nodes
//for machine in machines {
//    print("machine \(machine)")
//    var heap = Heap<Move>(elements: [Move(pressesA: 0, pressesB: 0, location: .zero)], isBefore: <)
//    while !heap.isEmpty {
//        let best = heap.removeFirst()
//
//        if best.location == machine.prize {
//            print("best \(best)")
//            fatalError()
//        }
//
//        if best.location.x > machine.prize.x || best.location.y > machine.prize.y {
//            // Now way to go back!
//        } else {
//            heap.insert(Move(pressesA: best.pressesA + 1, pressesB: best.pressesB, location: best.location + machine.buttonA))
//            heap.insert(Move(pressesA: best.pressesA, pressesB: best.pressesB + 1, location: best.location + machine.buttonB))
//        }
//    }
//}

var tokens = 0
for machine in machines {
    print("machine \(machine)")

    // Start with the maximum number of presses of B that doesn't overshoot
    let pressesB = min(machine.prize.x / machine.buttonB.x, machine.prize.y / machine.buttonB.y)

    var move = Move(pressesA: 0, pressesB: pressesB, location: machine.buttonB * pressesB)
    print("starting move \(move)")

    // Now trade in presses of B for A, avoiding overshooting
    while move.pressesB > 0 && move.location != machine.prize {
        move.pressesA += 1
        move.location += machine.buttonA

        // If this overshoots, take away B presses until it doesn't
        while move.pressesB > 0 && (move.location.x > machine.prize.x || move.location.y > machine.prize.y) {
            move.pressesB -= 1
            move.location -= machine.buttonB
        }
    }

    if move.location == machine.prize {
        print("winning move \(move)")
        tokens += move.cost
    } else {
        print("can't win")
    }
}
print("\(tokens)")
