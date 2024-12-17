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

let computer = Computer()
let output = computer.run()
print("\(output.map { String($0) }.joined(separator: ","))")

print("a \(computer.a)")
print("b \(computer.b)")
print("c \(computer.c)")
