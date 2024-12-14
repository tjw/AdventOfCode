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

do {
    let machines = Input.sections().map { section in
        let line = section.joined(separator: " ")
        return Machine(line: line)
    }

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
    assert(tokens == 30973)
}

do {
    let machines = Input.sections().map { section in
        let line = section.joined(separator: " ")
        let machine = Machine(line: line)
        return Machine(buttonA: machine.buttonA, buttonB: machine.buttonB, prize: Location2D(x: machine.prize.x + 10000000000000, y: machine.prize.y + 10000000000000))
    }

    var tokens = 0
    for machine in machines {
        print("machine \(machine)")

        /*
         Need to solve the system of linear Diophatine equations:

         A * Ax + B * Bx = Px
         A * Ay + B * By = Py

         Isolate A in both:

         A = (Px - B * Bx)/Ax
         A = (Py - B * By)/Ay

         Set equal to each other:

         (Px - B * Bx)/Ax = (Py - B * By)/Ay

         Solve for B:

         Ay * (Px - B * Bx) = Ax * (Py - B * By)
         Ay * Px - B * Ay * Bx = Ax * Py - B * Ax * By

         B * Ax * By - B * Ay * Bx = Ax * Py - Ay * Px
         B * (Ax * By - Ay * Bx) = Ax * Py - Ay * Px
         B = (Ax * Py - Ay * Px) / (Ax * By - Ay * Bx)

         Repeat to find B:

         A * Ax + B * Bx = Px
         A * Ay + B * By = Py

         B * Bx = Px - A * Ax
         B * By = Py - A * Ay

         B = (Px - A * Ax)/Bx
         B = (Py - A * Ay)/By

         (Px - A * Ax)/Bx = (Py - A * Ay)/By

         By*(Px - A * Ax) = Bx*(Py - A * Ay)

         By * Px - A By * Ax = Bx * Py - A * Bx * Ay

         A * Bx * Ay - A * By * Ax = Bx * Py - By * Px

         A * (Bx * Ay - By * Ax) = Bx * Py - By * Px

         A = (Bx * Py - By * Px) / (Bx * Ay - By * Ax)

         So we end up with:

         A = (Bx * Py - By * Px) / (Bx * Ay - Ax * By)
         B = (Ax * Py - Ay * Px) / (Ax * By - Bx * Ay)

         */

        let Ax = machine.buttonA.x
        let Ay = machine.buttonA.y
        let Bx = machine.buttonB.x
        let By = machine.buttonB.y
        let Px = machine.prize.x
        let Py = machine.prize.y

        let AN = (Bx * Py - By * Px)
        let AD = (Bx * Ay - Ax * By)

        let BN = (Ax * Py - Ay * Px)
        let BD = (Ax * By - Bx * Ay)

        if AN % AD != 0 || BN % BD != 0 {
            print("No solution")
            continue
        }

        let A = AN / AD
        let B = BN / BD
        print("A \(A)")
        print("B \(B)")

        tokens += A * costA + B * costB
    }

    print("\(tokens)")
    assert(tokens == 95688837203288)
}
