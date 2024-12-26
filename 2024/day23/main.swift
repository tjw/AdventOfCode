//
//  main.swift
//  day23
//
//  Created by Timothy Wood on 12/25/24.
//

import Foundation

class Computer : Hashable {
    let name: String
    var connections = Set<Computer>()

    init(name: String) {
        self.name = name
    }

    static func == (lhs: Computer, rhs: Computer) -> Bool {
        return lhs.name == rhs.name
    }
    func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
    }

}

var computerByName = [String:Computer]()

func findComputer(_ name: String) -> Computer {
    if let computer = computerByName[name] {
        return computer
    }
    let computer = Computer(name: name)
    computerByName[name] = computer
    return computer
}

for line in Input.lines() {
    let names = line.split(separator: "-")
    assert(names.count == 2)

    let a = findComputer(String(names[0]))
    let b = findComputer(String(names[1]))

    assert(a.connections.contains(b) == false)
    a.connections.insert(b)

    assert(b.connections.contains(a) == false)
    b.connections.insert(a)
}

var triples = Set<String>()

for computer in computerByName.values {
    for connection in computer.connections {
        var shared = computer.connections.intersection(connection.connections)
        if !shared.isEmpty {
            for neighbor in shared {
                if computer.name.hasPrefix("t") || connection.name.hasPrefix("t") || neighbor.name.hasPrefix("t") {
                    let triple = [computer.name, connection.name, neighbor.name].sorted().joined(separator: ",")
                    triples.insert(triple)
                }
            }
        }
    }
}

for triple in Array(triples).sorted() {
    print("\(triple)")
}

print("\(triples.count)")
assert(triples.count == 1302)
