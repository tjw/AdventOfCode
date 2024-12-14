//
//  Int.swift
//  AdventOfCode-2024
//
//  Created by Timothy Wood on 12/12/24.
//


// google scrounging rather than re-processing my time in Number Theory class

func gcd(_ a: Int, _ b: Int) -> Int {
  let r = a % b
  if r != 0 {
    return gcd(b, r)
  } else {
    return b
  }
}

// Returns (s,t,d) where s and t are needed below and d is the divisor
func extended_gcd(_ a: Int, _ b: Int) -> (Int, Int, Int) {
    if b == 0 {
        return (1, 0, a)
    } else {
        let (s, t, g) = extended_gcd(b, a % b)
        return (t, s - (a / b) * t, g)
    }
}

struct Diophantine {

    // Find a solution for a*x + b*y = c
    init(a: Int, b: Int, c: Int) {
        let (s, t, d) = extended_gcd(a, b)
        //print("extended_gcd(\(a)), \(b) -> (\(s), \(t), \(d))")
        if d == 1 || c % d != 0 {
            // No solutions
            self.d = 1
            self.x0 = 0
            self.y0 = 0
            self.xStep = 0
            self.yStep = 0
            return
        }

        self.d = d

        // Find x0, y0, one possible solution
        let e = c/d
        self.x0 = s*e
        self.y0 = t*e

        //print("x0 \(x0), y0 \(y0)")
        assert(a * x0 + b * y0 == c)

        /*
         All other solutions (infinitely many), are of the form

         x = x0 + (b/d) * n
         y = y0 - (a/d) * n

         */
        self.xStep = (b/d)
        self.yStep = -(a/d)
    }

    var valid: Bool {
        return d != 1
    }

    let d: Int
    let x0: Int
    let y0: Int

    let xStep: Int
    let yStep: Int

    subscript(_ n: Int) -> (Int, Int) {
        return (x0 + xStep * n, y0 + yStep * n)
    }
}
