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

    init(buttonA: Location2D, buttonB: Location2D, prize: Location2D) {
        self.buttonA = buttonA
        self.buttonB = buttonB
        self.prize = prize
    }
}

let costA = 3
let costB = 1

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

//do {
//    let machines = Input.sections().map { section in
//        let line = section.joined(separator: " ")
//        return Machine(line: line)
//    }
//    //print("machines \(machines)")
//
//    var tokens = 0
//    for machine in machines {
//        print("machine \(machine)")
//
//        // Start with the maximum number of presses of B that doesn't overshoot
//        let pressesB = min(machine.prize.x / machine.buttonB.x, machine.prize.y / machine.buttonB.y)
//
//        var move = Move(pressesA: 0, pressesB: pressesB, location: machine.buttonB * pressesB)
//        print("starting move \(move)")
//
//        // Now trade in presses of B for A, avoiding overshooting
//        while move.pressesB > 0 && move.location != machine.prize {
//            move.pressesA += 1
//            move.location += machine.buttonA
//
//            // If this overshoots, take away B presses until it doesn't
//            while move.pressesB > 0 && (move.location.x > machine.prize.x || move.location.y > machine.prize.y) {
//                move.pressesB -= 1
//                move.location -= machine.buttonB
//            }
//        }
//
//        if move.location == machine.prize {
//            print("winning move \(move)")
//            tokens += move.cost
//        } else {
//            print("can't win")
//        }
//    }
//    print("\(tokens)")
////    assert(tokens == 30973)
//}

do {
    let machines = Input.sections().map { section in
        let line = section.joined(separator: " ")
        let machine = Machine(line: line)
        return Machine(buttonA: machine.buttonA, buttonB: machine.buttonB, prize: machine.prize * 10000000000000)
    }

    var tokens = 0
    for machine in machines {
        print("machine \(machine)")

        let buttonA = machine.buttonA
        let buttonB = machine.buttonB
        let prize = machine.prize

        /*
         Need to solve the system of linear Diophatine equations:

         A * buttonA.x + B * buttonB.x = prize.x
         A * buttonA.y + B * buttonB.y = prize.y

         adding the two equations we get a single equation of two variables

         A * (buttonA.x + buttonA.y) + B * (buttonB.x + buttonB.y) = prize.x + prize.y

         Repackage this into the form

         ax + by = c

         where x and y are the unknowns (our A and B here)
         */

        let a = (buttonA.x + buttonA.y)
        let b = (buttonB.x + buttonB.y)
        let c = prize.x + prize.y

        let (x0, y0, d) = extended_gcd(a, b)
        print("extended_gcd(\(a), \(b) -> (\(x0), \(y0), \(d))")
        if d == 1 || c % d != 0 {
            // No solutions
            print("No solution")
            continue
        }

        let x = x0 * (c / d)
        let y = y0 * (c / d)

        print("x \(x), y \(y)")

        let v = a * x + b * y // THIS OVERFLOWS, but doing it in bc it produces the right value for c
        print("v \(v), c \(c)")
        // Use the Euclidean algorithm to find s and t such that a*s + b*t = d

    }
    print("\(tokens)")
}
