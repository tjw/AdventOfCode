//
//  main.swift
//  day16
//
//  Created by Timothy Wood on 12/17/22.
//

import Foundation

class Node : CustomStringConvertible {

    let name: String
    let rate: Int
    let neighbors: [String]

    init(name: String, rate: Int, neighbors: [String]) {
        self.name = name
        self.rate = rate
        self.neighbors = neighbors
    }

    var description: String {
        return name
    }

}

let nodes = Input.lines().map { line in
    let regex = /Valve ([A-Z]+) has flow rate=([0-9]+); tunnel(s?) lead(s?) to valve(s?) ([A-Z, ]+)/
    let match = try! regex.firstMatch(in: line)!
    let name = match.1
    let rate = Int(match.2)!
    let neighbors = match.6.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
    return Node(name: String(name), rate: rate, neighbors: neighbors)
}
let nodeByName = Dictionary(uniqueKeysWithValues: nodes.map { node in
    return (node.name, node)
})

print("nodes = \(nodes)")

// emit dot description
print("graph day16 {")
for node in nodes {
    // only emit edges once
    for dest in node.neighbors {
        if dest > node.name {
            print("  \(node.name) -- \(dest)")
        }
    }
}
print("}")

let currentNode = "AA"

// Calculate all pairs shortest paths for the graph just counting the number of hops (minutes) to make the trip. Not doing the Floyd-Warshall/whatever algorithm.

struct Path : Hashable {
    let a, b: String

    // Since our graph is not directed, a->b and b->a are the same length.
    init(a: String, b: String) {
        if a < b {
            self.a = a
            self.b = b
        } else {
            self.a = b
            self.b = a
        }
    }
}

let bestPath: [Path:Int]
do {
    var current = [Path:Int]()

    for source in nodes {
        print("source \(source)")
        var length = 1
        var nextNodes = source.neighbors
        var visited = Set<String>([source.name])
        print("  nextNodes \(nextNodes)")

        while !nextNodes.isEmpty {
            var newNodes = [String]()

            for dest in nextNodes {
                print("  dest \(dest)")
                let pair = Path(a: source.name, b: dest)

                if let best = current[pair] {
                    assert(best == length) // undirected
                } else {
                    current[pair] = length
                    print("    pair \(pair) length \(length)")
                }

                visited.insert(dest)

                for name in nodeByName[dest]!.neighbors {
                    if !visited.contains(name) {
                        newNodes.append(name)
                    }
                }
            }

            nextNodes = newNodes
            length += 1
            print("  nextNodes \(nextNodes)")
        }
    }
}



// Mark valves with zero flow as already open
let initialOpenValves = nodes.filter { $0.rate == 0 }
