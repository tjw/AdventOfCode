//
//  main.swift
//  day7
//
//  Created by Timothy Wood on 12/3/24.
//

import Foundation

enum Source {
    case constant(UInt16)

    // Gates can be implicitly created by name before their description is read, so we only store the name here
    case gate(String)

    init(_ string: String) {
        if let number = UInt16(string) {
            self = .constant(number)
        } else {
            self = .gate(string)
        }
    }

    func evaluate(gates: [String:Gate]) -> UInt16 {
        switch self {
        case .constant(let value):
            return value
        case .gate(let name):
            return gates[name]!.evaluate(gates: gates)
        }
    }
}

enum Operation {
    case ASSIGN(Source)
    case AND(Source, Source)
    case OR(Source, Source)

    // The example doesn't seem to allow the source here to be a constant, but why not.
    case NOT(Source)

    // The example doesn't seem to allow the shift amount (the second value) to be a gate output, but it's easier to do so
    case LSHIFT(Source, Source)
    case RSHIFT(Source, Source)

    func evaluate(gates: [String:Gate]) -> UInt16 {
        switch self {
        case .ASSIGN(let a):
            return a.evaluate(gates: gates)
        case .AND(let a, let b):
            return a.evaluate(gates: gates) & b.evaluate(gates: gates)
        case .OR(let a , let b):
            return a.evaluate(gates: gates) | b.evaluate(gates: gates)
        case .NOT(let a):
            return ~a.evaluate(gates: gates)
        case .LSHIFT(let a, let b):
            return a.evaluate(gates: gates) << b.evaluate(gates: gates)
        case .RSHIFT(let a, let b):
            return a.evaluate(gates: gates) >> b.evaluate(gates: gates)
        }
    }
}

class Gate {
    let name: String // This is the output
    let operation: Operation

    // Cached when calculated
    var value: UInt16?

    static let binaryEx = /([a-z0-9]+) (AND|OR|LSHIFT|RSHIFT) ([a-z0-9]+) -> ([a-z]+)/
    static let unaryEx = /NOT ([a-z0-9]+) -> ([a-z]+)/
    static let contantEx = /([a-z0-9]+) -> ([a-z]+)/

    init(_ string: String) {
        if let match = string.wholeMatch(of: Self.binaryEx) {
            self.name = String(match.4)

            let a = Source(String(match.1))
            let b = Source(String(match.3))

            switch match.2 {
            case "AND": self.operation = .AND(a, b)
            case "OR": self.operation = .OR(a, b)
            case "LSHIFT": self.operation = .LSHIFT(a, b)
            case "RSHIFT": self.operation = .RSHIFT(a, b)
            default:
                fatalError()
            }
        } else if let match = string.wholeMatch(of: Self.unaryEx) {
            self.name = String(match.2)

            let a = Source(String(match.1))
            self.operation = .NOT(a)
        } else if let match = string.wholeMatch(of: Self.contantEx) {
            self.name = String(match.2)
            self.operation = .ASSIGN(Source(String(match.1)))
        } else {
            fatalError()
        }
    }

    func evaluate(gates: [String:Gate]) -> UInt16 {
        if let value = value {
            return value
        }
        let value = operation.evaluate(gates: gates)
        print("\(value) -> \(name)")
        self.value = value
        return value
    }
}

let gates: [String:Gate] = {
    var result = [String:Gate]()
    for line in Input.lines() {
        let gate = Gate(line)
        assert(result[gate.name] == nil)
        result[gate.name] = gate
    }

    return result
}()

do {
    let value = gates["a"]!.evaluate(gates: gates)
    print("\(value)")
    assert(value == 16076)
}

do {
    gates.forEach { _, gate in gate.value = nil }
    gates["b"]!.value = 16076

    let value = gates["a"]!.evaluate(gates: gates)
    print("\(value)")
    assert(value == 2797)
}
