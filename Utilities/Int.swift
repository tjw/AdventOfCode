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

func extended_gcd(_ a: Int, _ b: Int) -> (Int, Int, Int) {
    if b == 0 {
        return (1, 0, a)
    } else {
        let (s, t, g) = extended_gcd(b, a % b)
        return (t, s - (a / b) * t, g)
    }
}
