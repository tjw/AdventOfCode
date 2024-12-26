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

do {
    var triples = Set<String>()

    for computer in computerByName.values {
        for connection in computer.connections {
            let shared = computer.connections.intersection(connection.connections)
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

    print("\(triples.count)")
    assert(triples.count == 1302)
}

do {
    // Looking at https://en.wikipedia.org/wiki/Bron–Kerbosch_algorithm for maximal complete subgraph or clique, which is NP hard. Not sure if the input set is small enough for this to work.

    var cliques = Set<String>()

    func BronKerbosch1(R: Set<Computer>, P: Set<Computer>, X: Set<Computer>) {
        if P.isEmpty && X.isEmpty {
            let clique = R.map({ $0.name }).sorted().joined(separator: ",")
            cliques.insert(clique)
            return
        }

        var PN = P
        var XN = X

        for v in P {
            BronKerbosch1(R: R.union(Set([v])), P: PN.intersection(v.connections), X: XN.intersection(v.connections))
            PN.remove(v)
            XN.insert(v)
        }
    }

    BronKerbosch1(R: [], P: Set(computerByName.values), X: [])

    let maximumClique = cliques.sorted(by: { (a:String, b:String) -> Bool in return a.count > b.count }).first!
    print("\(maximumClique)")
    assert(maximumClique == "cb,df,fo,ho,kk,nw,ox,pq,rt,sf,tq,wi,xz")
}
