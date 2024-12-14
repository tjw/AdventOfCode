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

//do {
//    let machines = Input.sections().map { section in
//        let line = section.joined(separator: " ")
//        let machine = Machine(line: line)
//        return Machine(buttonA: machine.buttonA, buttonB: machine.buttonB, prize: Location2D(x: machine.prize.x * 10000000000000, y: machine.prize.y * 10000000000000))
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
//        // At this point, either x or y is too high to add any more presses of B, but the other is too low and will require possibly many trades of A for B to get in the neighborhood. Each addition of A make make room for another B though (delta may be negative for that component).
//        let delta = machine.buttonA - machine.buttonB
//        print("delta \(delta)")
////        let pressesA =
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
//            print("move \(move), prize offset \(machine.prize - move.location)")
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

/* Tried adding the equations for x and y positions and get a solution that works for the combined equation but doesn't translate to the individuals
do {
    let machines = Input.sections().map { section in
        let line = section.joined(separator: " ")
        let machine = Machine(line: line)
        return Machine(buttonA: machine.buttonA, buttonB: machine.buttonB, prize: Location2D(x: machine.prize.x + 10000000000000, y: machine.prize.y + 10000000000000))
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
        let diophantine = Diophantine(a: a, b: b, c: c)

        if !diophantine.valid {
            // No solutions
            print("No solution")
            continue
        }

//        let (s, t, d) = extended_gcd(a, b)
//        print("extended_gcd(\(a)), \(b) -> (\(s), \(t), \(d))")
//        if d == 1 || c % d != 0 {
//            // No solutions
//            print("No solution")
//            continue
//        }
//
//        // Find x0, y0, one possible solution
//        let e = c/d
//        let x0 = s*e
//        let y0 = t*e
//
//        print("x0 \(x0), y0 \(y0)")
//        assert(a * x0 + b * y0 == c)

        /*
         All other solutions (infinitely many), are of the form

         x = x0 + (b/d) * n
         y = y0 - (a/d) * n

         */

        // We need non-negative numbers of button pushes
        let x, y: Int
        if diophantine.y0 < 0 {
            // Find n such that y will end up with the smallest positive value
            let n = diophantine.y0 / diophantine.yStep - 1
            (x, y) = diophantine[n]
        } else {
            assert(diophantine.x0 >= 0) // might need to handle this case too
            (x, y) = diophantine[0]
        }
        print("x \(x), y \(y)")

        assert(x * machine.buttonA + y * machine.buttonB == machine.prize)

//        let v = a * x0 + b * y0
//        print("v \(v), c \(c)")

//        let n = y0 / (a/d) - 1
//        print("n \(n)")
//        let x1 = x0 + (b/d) * n
//        let y1 = y0 - (a/d) * n
//        print("x1 \(x1), y1 \(y1)")
//        print("v1 \(a * x1 + b * y1)")

    }
    print("\(tokens)")
}
*/

/*
do {
    let machines = Input.sections().map { section in
        let line = section.joined(separator: " ")
        let machine = Machine(line: line)
        return Machine(buttonA: machine.buttonA, buttonB: machine.buttonB, prize: Location2D(x: machine.prize.x + 10000000000000, y: machine.prize.y + 10000000000000))
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

         */

//        let a = (buttonA.x + buttonA.y)
//        let b = (buttonB.x + buttonB.y)
//        let c = prize.x + prize.y
        let diophantineX = Diophantine(a: buttonA.x, b: buttonB.x, c: prize.x)
        let diophantineY = Diophantine(a: buttonA.y, b: buttonB.y, c: prize.y)

        if !diophantineX.valid || !diophantineY.valid {
            // No solutions
            print("No solution")
            continue
        }

        print("diophantineX \(diophantineX)")
        print("diophantineY \(diophantineY)")

        assert(diophantineX.x0 * buttonA.x + diophantineX.y0 * buttonB.x == prize.x)
        assert(diophantineY.x0 * buttonA.y + diophantineY.y0 * buttonB.y == prize.y)

        /*
        // We need non-negative numbers of button pushes
        let x, y: Int
        if diophantine.y0 < 0 {
            // Find n such that y will end up with the smallest positive value
            let n = diophantine.y0 / diophantine.yStep - 1
            (x, y) = diophantine[n]
        } else {
            assert(diophantine.x0 >= 0) // might need to handle this case too
            (x, y) = diophantine[0]
        }
        print("x \(x), y \(y)")

        assert(x * machine.buttonA + y * machine.buttonB == machine.prize)
*/
    }
    print("\(tokens)")
}
*/

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
