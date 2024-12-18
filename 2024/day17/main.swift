//
//  main.swift
//  day17
//
//  Created by Timothy Wood on 12/16/24.
//

import Foundation

// 3-bit, 0-7 only
enum Instruction : Int {
    case adv = 0
    case bxl = 1
    case bst = 2
    case jnz = 3
    case bxc = 4
    case out = 5
    case bdv = 6
    case cdv = 7
}

class Computer {
    var a: Int
    var b: Int
    var c: Int

    var ip: Int = 0

    var program: [Instruction]

    init() {
        let lines = Input.lines()
        assert(lines.count == 4)

        assert(lines[0].hasPrefix("Register A: "))
        a = Int(lines[0].split(separator: ": ")[1])!

        assert(lines[1].hasPrefix("Register B: "))
        b = Int(lines[1].split(separator: ": ")[1])!

        assert(lines[2].hasPrefix("Register C: "))
        c = Int(lines[2].split(separator: ": ")[1])!

        assert(lines[3].hasPrefix("Program: "))
        program = String(lines[3].split(separator: ": ")[1]).numbers(separatedBy: ",").map { Instruction(rawValue: $0)! }

        assert(program.count % 2 == 0, "Want an even number of instructions to avoid having to check when reading the operand")
    }

    func combo(_ operand: Int) -> Int {
        if operand <= 3 {
            return operand
        }
        if operand == 4 {
            return a
        }
        if operand == 5 {
            return b
        }
        if operand == 6 {
            return c
        }
        fatalError()
    }

    func run() -> [Int] {
        var output: [Int] = []

        ip = 0

        while ip < program.count {
            assert(ip % 2 == 0, "Want this to be even to avoid having to bounds check when reading the operand")

            let instruction = program[ip]
            let literalOperand = program[ip + 1].rawValue
            ip += 2

            switch instruction {
            case .adv:
                let numerator = a
                let denominator = 1 << combo(literalOperand) // 2^op
                let result = numerator / denominator
                a = result
            case .bxl:
                let value = b ^ literalOperand
                b = value
            case .bst:
                let value = combo(literalOperand)
                b = value % 8
            case .jnz:
                if a == 0 {
                    continue
                }
                ip = literalOperand // we increment ip by two above so that this overrides it
            case .bxc:
                b = b ^ c
            case .out:
                let value = combo(literalOperand) % 8
                output.append(value)
            case .bdv:
                fatalError()
            case .cdv:
                let numerator = a
                let denominator = 1 << combo(literalOperand) // 2^op
                let result = numerator / denominator
                c = result
            }

        }

        return output
    }
}

/*
do {
    let computer = Computer()
    let output = computer.run()
    print("\(output.map { String($0) }.joined(separator: ","))")

    print("a \(computer.a)")
    print("b \(computer.b)")
    print("c \(computer.c)")
}
*/

// Brute force doesn't work, unsurprisingly
/*
do {
    let computer = Computer()
    let originalB = computer.b
    let originalC = computer.c
    let rawProgram = computer.program.map { $0.rawValue }

    for a in 0..<1_000_000_000 {
        computer.a = a
        computer.b = originalB
        computer.c = originalC

        let output = computer.run()

        if output == rawProgram {
            print("\(a)")
            break
        }
    }
}
*/

/*
 Disassemble the program:

 2,4,1,1,7,5,1,5,4,0,0,3,5,5,3,0

start:
 2,4: bst $A
 1,1: bxl #1
 7,5: cdv $B
 1,5: bxl #5
 4,0: bxc 0
 0,3: adv #3
 5,5: out $B
 3,0: jnz start

 // Try commenting it
start:
  bst $A     // B = A % 8
  bxl #1     // B = B ^ 1
  cdv $B     // C = A / (1 << B)
  bxl #5     // B = B ^ 5
  bxc 0      // B = B ^ C
  adv #3     // A = A / (1 << 3)
  out $B     // output B % 8
  jnz start  // loop unless A == 0

 */

// Try the original program in decompiled code, expecting 6,4,6,0,4,5,7,2,7
// This successfully produces the expected output
do {
    var a = 64196994
    var b = 0
    var c = 0

    var output = [Int]()

    while a != 0 {
        print("  a: \(a), b: \(b), c: \(c), output \(b % 8)")
        b = a % 8

        print("  a: \(a), b: \(b), c: \(c), output \(b % 8)")
        b = b ^ 1

        print("  a: \(a), b: \(b), c: \(c), output \(b % 8)")
        c = a / (1 << b)

        print("  a: \(a), b: \(b), c: \(c), output \(b % 8)")
        b = b ^ 5

        print("  a: \(a), b: \(b), c: \(c), output \(b % 8)")
        b = b ^ c

        print("  a: \(a), b: \(b), c: \(c), output \(b % 8)")
        a = a / (1 << 3)

        output.append(b % 8)
        print("a: \(a), b: \(b), c: \(c), output \(b % 8)")
    }

    //print(output)
}

print("--------")

// Now, write the inverse program that starts with A = 0 (the previous termination condition) and where instead of outputting values, we read them from the program
do {
    var a = 0
    var b = 0
    var c = 0

    // var input = [2,4,1,1,7,5,1,5,4,0,0,3,5,5,3,0]
    var input = [6,4,6,0,4,5,7,2,7]

    while !input.isEmpty {
        // output b % 8; set the bottom three bits of b the the input value
        let v = input.last!
        input.removeLast()
        b = (b & ~0x7) | v
        print("a: \(a), b: \(b), c: \(c), input \(v)")

        // a = a / (1 << 3)
        a = a * (1 << 3)
        print("  a: \(a), b: \(b), c: \(c), input \(v)")

        // b = b ^ c
        c = b ^ c
        print("  a: \(a), b: \(b), c: \(c), input \(v)")

        // b = b ^ 5
        b = b ^ 5
        print("  a: \(a), b: \(b), c: \(c), input \(v)")

        // c = a / (1 << b)
        a = c * (1 << b) //  | (c & ~(1 << b))
        print("  a: \(a), b: \(b), c: \(c), input \(v)")

        // b = b ^ 1
        b = b ^ 1
        print("  a: \(a), b: \(b), c: \(c), input \(v)")

        // b = a % 8
        a = (a & ~0x7) | b
        print("  a: \(a), b: \(b), c: \(c), input \(v)")

        //print("a: \(a), b: \(b), c: \(c)")
    }

    print(a)
}
