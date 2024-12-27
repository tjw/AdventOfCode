//
//  main.swift
//  day24
//
//  Created by Timothy Wood on 12/25/24.
//

import Foundation

// Very similar to 2015 day 7

enum Operation : Comparable {
    case CONSTANT(Int)
    case AND(String, String)
    case OR(String, String)
    case XOR(String, String)

    var opName: String {
        switch self {
        case .CONSTANT(_): "CONSTANT"
        case .AND(_, _): "AND"
        case .OR(_, _): "OR"
        case .XOR(_, _): "XOR"
        }
    }

    func evaluate(gates: [String:Gate]) -> Int {
        switch self {
        case .CONSTANT(let c):
            return c
        case .AND(let a, let b):
            return gates[a]!.evaluate(gates: gates) & gates[b]!.evaluate(gates: gates)
        case .OR(let a , let b):
            return gates[a]!.evaluate(gates: gates) | gates[b]!.evaluate(gates: gates)
        case .XOR(let a , let b):
            return gates[a]!.evaluate(gates: gates) ^ gates[b]!.evaluate(gates: gates)
        }
    }

    func addInputs(_ inputs: inout Set<String>, gates: [String:Gate]) {
        switch self {
        case .CONSTANT:
            break
        case .AND(let a, let b), .OR(let a, let b), .XOR(let a, let b):
            inputs.insert(a)
            inputs.insert(b)

            gates[a]!.addInputs(&inputs, gates: gates)
            gates[b]!.addInputs(&inputs, gates: gates)
        }
    }

    func addConstants(_ constants: inout Set<String>, gates: [String:Gate]) {
        switch self {
        case .CONSTANT:
            break
        case .AND(let a, let b), .OR(let a, let b), .XOR(let a, let b):
            gates[a]!.addConstants(&constants, gates: gates)
            gates[b]!.addConstants(&constants, gates: gates)
        }
    }
}

class Gate : Comparable {
    let name: String
    var operation: Operation

    static let binaryEx = /([a-z0-9]+) (AND|OR|XOR) ([a-z0-9]+) -> ([a-z0-9]+)/

    init(_ string: String) {
        let match = string.wholeMatch(of: Self.binaryEx)!
        self.name = String(match.4)

        // Make xN always appear before yN if in the same expression (at least for dot output)
        var a = String(match.1)
        var b = String(match.3)
        if a > b {
            swap(&a, &b)
        }

        switch match.2 {
        case "AND": self.operation = .AND(a, b)
        case "OR": self.operation = .OR(a, b)
        case "XOR": self.operation = .XOR(a, b)
        default:
            fatalError()
        }
    }

    init(name: String, constant: Int) {
        self.name = name
        self.operation = .CONSTANT(constant)
    }

    func reset() {
        value = nil
    }

    var value: Int?

    func evaluate(gates: [String:Gate]) -> Int {
        if let value = value {
            return value
        }
        let value = operation.evaluate(gates: gates)
        //print("\(value) -> \(name)")
        self.value = value
        return value
    }

    func addInputs(_ inputs: inout Set<String>, gates: [String:Gate]) {
        operation.addInputs(&inputs, gates: gates)
    }

    func addConstants(_ constants: inout Set<String>, gates: [String:Gate]) {
        if case .CONSTANT = operation {
            constants.insert(name)
        } else {
            operation.addConstants(&constants, gates: gates)
        }
    }

    static func < (lhs: Gate, rhs: Gate) -> Bool {
        if lhs.name < rhs.name {
            return true
        }
        if lhs.name == rhs.name {
            let lOp = lhs.operation.opName
            let rOp = lhs.operation.opName
            if lOp < rOp {
                return true
            } else if lOp > rOp {
                return false
            }
        }
        return false
    }

    static func == (lhs: Gate, rhs: Gate) -> Bool {
        return lhs.name == rhs.name && lhs.operation == rhs.operation
    }


    func printDot() {
        let a, b: String
        let opName: String

        switch operation {
        case .CONSTANT(let int):
            return
        case .AND(let string, let string2):
            a = string
            b = string2
            opName = "AND"
        case .OR(let string, let string2):
            a = string
            b = string2
            opName = "OR"
        case .XOR(let string, let string2):
            a = string
            b = string2
            opName = "XOR"
        }

        print("\(a) -> \(name)_op;")
        print("\(b) -> \(name)_op;")
        print("\(name)_op [label=\"\(opName)\"];")
        print("\(name)_op -> \(name);")
    }
}

var gates = [String:Gate]()
let sections = Input.sections()

sections[0].forEach { line in
    let items = line.split(separator: ":")
    assert(items.count == 2)

    let name = String(items[0])
    let value = Int(items[1].trimmingCharacters(in: .whitespaces))!
    assert(value == 0 || value == 1)

    let gate = Gate(name: name, constant: value)
    assert(gates[name] == nil)
    gates[name] = gate
}

sections[1].forEach { line in
    let gate = Gate(line)
    assert(gates[gate.name] == nil)
    gates[gate.name] = gate
}

let names = gates.keys.compactMap { $0.hasPrefix("z") ? $0 : nil } .sorted()

//print("digraph graphname {")
//for gate in gates.values.sorted() {
//    gate.printDot()
//}
//print("}")

//do {
//    var result: Int = 0
//    for name in names.sorted() {
//        // Looks like all bits are specified, but not assuming it
//        let shift = Int(String(name.dropFirst()))!
//        let value = gates[name]!.evaluate(gates: gates)
//        print("\(name) -> \(value)")
//
//        result |= (value << shift)
//    }
//    print("\(result)")
//    assert(result == 69201640933606)
//}


for name in names {
    let gate = gates[name]!

    // It looks like none of the z values depend on another directly (though they have common subexpressions)

    var inputs = Set<String>()
    gate.addInputs(&inputs, gates: gates)
//    print("\(name) depends on \(inputs.sorted())")
//    print("-- \(inputs.compactMap { $0.hasPrefix("z") ? $0 : nil })")

    // Every zN should depend on all xN-1, yN-1 except for the first
//    do {
//        var zIdx = Int(name.dropFirst())!
//        var requiredDependencies = Set<String>()
//
//        while true {
//            requiredDependencies.insert(String(format: "x%02d", zIdx))
//            requiredDependencies.insert(String(format: "y%02d", zIdx))
//            if zIdx == 0 {
//                break
//            }
//            zIdx -= 1
//        }
//
//        let baseInputs = inputs.filter { $0.hasPrefix("x") || $0.hasPrefix("y") }
//        if requiredDependencies != baseInputs {
//            let missing = requiredDependencies.subtracting(baseInputs)
//            if !missing.isEmpty {
//                print("## \(name) is missing inputs \(missing.sorted())")
//            }
//            let extra = baseInputs.subtracting(requiredDependencies)
//            if !extra.isEmpty {
//                print("## \(name) is extra inputs \(extra.sorted())")
//            }
//        }
//    }

//    var constants = Set<String>()
//    gate.addConstants(&constants, gates: gates)
//    print("\(name) uses constants \(constants.sorted())")

    // IDEA: Redo the "math" as a symbolic flow. For each zN, it should only depend on xN, yN, xN-1, yN-1 (though the latter two could be expressed through other bits due to carries).
    // IDEA: Could maybe expand and simplify expressions, but not sure how we'd track
    // IDEA: After fully expanding/normalizing, could then try to canonocolize how the expression for earlier bits is expressed and if we can't normalize it to the correct operation, we at least know which is wrong, but not which gate it came from
    // IDEA: Can set a single bit in the inputs, run the machine and see if the output is wrong. Then each gate involved (i.e., those that had a value of one might be wrong, and those that had zero in the bit that was supposed to be one). The maybe do this for every bit and try to intersect the sets of gates involved in the error cases?
}

// Probe with x + y = z with a single bit in each of x and y set to the given value

func probe(x: Int, y: Int) {

    print("###")
    print("### Probe with x: \(x), y: \(y)")
    print("###")

    for idx in 0..<45 {
        gates[String(format: "x%02d", idx)]!.operation = .CONSTANT(0)
        gates[String(format: "y%02d", idx)]!.operation = .CONSTANT(0)
    }

    for idx in 0..<45 {
        print("## \(idx) ##")
        gates.forEach { $1.reset() }
        gates[String(format: "x%02d", idx)]!.operation = .CONSTANT(x)
        gates[String(format: "y%02d", idx)]!.operation = .CONSTANT(y)

        print("⬛️", terminator: "")
        for idx in (0..<45).reversed() {
            let x = gates[String(format: "x%02d", idx)]!
            if x.evaluate(gates: gates) == 1 {
                print("🟩", terminator: "")
            } else {
                print("⬜️", terminator: "")
            }
        }
        print("")

        print("⬛️", terminator: "")
        for idx in (0..<45).reversed() {
            let x = gates[String(format: "y%02d", idx)]!
            if x.evaluate(gates: gates) == 1 {
                print("🟩", terminator: "")
            } else {
                print("⬜️", terminator: "")
            }
        }
        print("")

        for idx in (0..<46).reversed() {
            let x = gates[String(format: "z%02d", idx)]!
            if x.evaluate(gates: gates) == 1 {
                print("🟩", terminator: "")
            } else {
                print("⬜️", terminator: "")
            }
        }

        print("")
        print("")

        gates[String(format: "x%02d", idx)]!.operation = .CONSTANT(0)
        gates[String(format: "y%02d", idx)]!.operation = .CONSTANT(0)
    }
}

//probe(x: 1, y: 0) // x9 outputs to z10, x18 outputs to z19, x22 outputs to z23, x27 outputs to z28
//probe(x: 0, y: 1) // y9 outputs to z10, y18 outputs to z19, x22 outputs to z23, x27 outputs to z28
//probe(x: 1, y: 1) // c9 stays in z9, c17 goes to z19, c18 stays in z18, c21 goes to c23, c22 stays in z22, c26 goes to z28


// Avoid building these strings over and over
let xNames = (0..<45).map { String(format: "x%02d", $0) }
let yNames = (0..<45).map { String(format: "y%02d", $0) }
let zNames = (0..<46).map { String(format: "z%02d", $0) }

// Force the inputs to zero
xNames.forEach { gates[$0]!.operation = .CONSTANT(0) }
yNames.forEach { gates[$0]!.operation = .CONSTANT(0) }

func countErrors(x: Int, y: Int) -> Int {
    print("### x \(x), y \(y)")

    var errors = 0

    for idx in 0..<45 {
        // Set the input bits
        gates.forEach { $1.reset() }
        gates[xNames[idx]]!.operation = .CONSTANT(x)
        gates[yNames[idx]]!.operation = .CONSTANT(y)

        // Check the outputs
        if x == 1 && y == 1 {
            // Carry should be at idx+1
            for zIdx in 0..<46 {
                let z = gates[zNames[zIdx]]!.evaluate(gates: gates)
                if zIdx == idx + 1 {
                    if z != 1 {
                        print("  idx \(idx), z\(zIdx) \(z)")
                        errors += 1
                    }
                } else {
                    if z != 0 {
                        print("  idx \(idx), z\(zIdx) \(z)")
                        errors += 1
                    }
                }
            }
        } else {
            // We don't consider x=0 y=0 since there are no operators that can manifest bits out of zeros (no NOT)
            // No carry
            for zIdx in 0..<46 {
                let z = gates[zNames[zIdx]]!.evaluate(gates: gates)
                if zIdx == idx {
                    if z != 1 {
                        print("  idx \(idx), z\(zIdx) \(z)")
                        errors += 1
                    }
                } else {
                    if z != 0 {
                        print("  idx \(idx), z\(zIdx) \(z)")
                        errors += 1
                    }
                }
            }
        }

        // Turn those bits off for the next loop
        gates[xNames[idx]]!.operation = .CONSTANT(0)
        gates[yNames[idx]]!.operation = .CONSTANT(0)
    }

    return errors
}

print("1/0 \(countErrors(x: 1, y: 0))")
print("0/1 \(countErrors(x: 0, y: 1))")
print("1/1 \(countErrors(x: 1, y: 1))")
