//
//  main.swift
//  day7
//
//  Created by Timothy Wood on 12/3/24.
//

import Foundation

enum Source {
    case constant(UInt16)
    case gate(Gate)
}

enum Operation {
    case AND(Source, Source)
    case OR(Source, Source)
    case NOT(Source)
    case LSHIFT(Source, UInt16)
    case RSHIFT(Source, UInt16)
}

class Gate {
    let name: String

    // Gates can be implicitly created by name before their description is read
    var operation: Operation!
    var output: Gate!

    static let binaryEx = /([a-z0-9]+) (AND|OR|LSHIFT|RSHIFT) ([a-z0-9]+) -> ([a-z]+)/
    static let unaryEx = /(NOT) ([a-z0-9]+) -> ([a-z]+)/

    init(_ string: String) {
        if let match = string.wholeMatch(of: Self.binaryEx) {
            fatalError()
        } else if let match = string.wholeMatch(of: Self.unaryEx) {
            fatalError()
        } else {
            fatalError()
        }
    }
}

let gates: [String:Gate] = {
    var result = [String:Gate]()
    for line in Input.lines() { line in
        // parse the output name first, should *not* exist yet
    }
}()
