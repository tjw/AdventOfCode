//
//  main.swift
//  day24
//
//  Created by Timothy Wood on 12/25/24.
//

import Foundation

// Very similar to 2015 day 7

var contants = [String:Int]()

let sections = Input.sections()
sections[0].forEach { line in
    let items = line.split(separator: ":")
    assert(items.count == 2)

    let name = String(items[0])
    let value = Int(items[1].trimmingCharacters(in: .whitespaces))!
    assert(value == 0 || value == 1)

    assert(contants[name] == nil)
    contants[name] = value
}

enum Operation {
    case AND(String, String)
    case OR(String, String)
    case XOR(String, String)

    func evaluate1(name: String, gates: [String:Gate]) -> Int {
        if let value = contants[name] {
            return value
        }
        return gates[name]!.evaluate(gates: gates)
    }

    func evaluate(gates: [String:Gate]) -> Int {
        switch self {
        case .AND(let a, let b):
            return evaluate1(name: a, gates: gates) & evaluate1(name: b, gates: gates)
        case .OR(let a , let b):
            return evaluate1(name: a, gates: gates) | evaluate1(name: b, gates: gates)
        case .XOR(let a , let b):
            return evaluate1(name: a, gates: gates) ^ evaluate1(name: b, gates: gates)
        }
    }
}

class Gate {
    let name: String
    let operation: Operation

    static let binaryEx = /([a-z0-9]+) (AND|OR|XOR) ([a-z0-9]+) -> ([a-z0-9]+)/

    init(_ string: String) {
        let match = string.wholeMatch(of: Self.binaryEx)!
        self.name = String(match.4)

        let a = String(match.1)
        let b = String(match.3)

        switch match.2 {
        case "AND": self.operation = .AND(a, b)
        case "OR": self.operation = .OR(a, b)
        case "XOR": self.operation = .XOR(a, b)
        default:
            fatalError()
        }
    }

    var value: Int?

    func evaluate(gates: [String:Gate]) -> Int {
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
    for line in sections[1] {
        let gate = Gate(line)
        assert(result[gate.name] == nil)
        result[gate.name] = gate
    }

    return result
}()

var result: Int = 0
let names = gates.keys.compactMap { $0.hasPrefix("z") ? $0 : nil }
for name in names.sorted() {
    // Looks like all bits are specified, but not assuming it
    let shift = Int(String(name.dropFirst()))!
    let value = gates[name]!.evaluate(gates: gates)
    print("\(name) -> \(value)")

    result |= (value << shift)
}
print("\(result)")
assert(result == 69201640933606)
