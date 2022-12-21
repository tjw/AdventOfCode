//
//  main.swift
//  day16
//
//  Created by Timothy Wood on 12/17/22.
//

import Foundation
import Algorithms

class Node : Equatable, CustomStringConvertible {
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

    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs === rhs
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

struct Path : Comparable, Hashable {
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

    static func < (lhs: Path, rhs: Path) -> Bool {
        if lhs.a < rhs.a {
            return true
        }
        if lhs.a > rhs.a {
            return false
        }
        if lhs.b < rhs.b {
            return true
        }
        return false
    }

}

let bestPath: [Path:Int]
do {
    var current = [Path:Int]()

    for source in nodes {
        //print("source \(source)")
        var length = 1
        var nextNodes = source.neighbors
        var visited = Set<String>([source.name])
        //print("  nextNodes \(nextNodes)")

        while !nextNodes.isEmpty {
            var newNodes = [String]()

            for dest in nextNodes {
                //print("  dest \(dest)")
                let pair = Path(a: source.name, b: dest)

                if let best = current[pair] {
                    assert(best <= length) // undirected
                } else {
                    current[pair] = length
                    //print("    pair \(pair) length \(length)")
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
            //print("  nextNodes \(nextNodes)")
        }
    }

    bestPath = current
}

//bestPath.keys.sorted().forEach { key in
//    print("\(key) \(bestPath[key]!)")
//}

// Mark valves with zero flow as already open
let initialOpenValves = nodes.filter { $0.rate == 0 }
print("initialOpenValves \(initialOpenValves)")
var availableValves = nodes.filter { $0.rate != 0 }
print("availableValves \(availableValves)")

enum Action : Equatable {
    case idle(Node) // initial state and when there are no more available valves to open
    case move(Node, Int)
}

struct State : Comparable, Equatable {
    var openValves: [Node]
    var pressureReleased: Int
    var actions: [Action] = []

    static func < (lhs: State, rhs: State) -> Bool {
        return lhs.pressureReleased < rhs.pressureReleased
    }

    var currentFlow: Int {
        openValves.reduce(0, { $0 + $1.rate })
    }
}

func process(action: Action, state: State, availableValves: [Node], time: Int, maxMinutes: Int) -> State {
    var updatedState = state
    updatedState.actions.append(action)

    let currentFlow = state.currentFlow
    updatedState.pressureReleased += currentFlow

    if time == maxMinutes {
        return updatedState
    }

    let location: Node
    var updatedAvailableValves: [Node]

    switch action {
    case .idle(let valve):
        location = valve
        updatedAvailableValves = availableValves
    case .move(let destination, let remainingTime):
        if remainingTime > 0 {
            return process(action: .move(destination, remainingTime - 1), state: updatedState, availableValves: availableValves, time: time + 1, maxMinutes: maxMinutes)
        } else {
            location = destination
            updatedState.openValves = updatedState.openValves + [destination]
            updatedAvailableValves = availableValves.filter { $0 != destination }
        }
    }

    if updatedAvailableValves.isEmpty {
        return process(action: .idle(location), state: updatedState, availableValves: updatedAvailableValves, time: time + 1, maxMinutes: maxMinutes)
    }

    var bestState = updatedState
    for valveIndex in 0..<updatedAvailableValves.count {
        let valve = updatedAvailableValves[valveIndex]
        let path = Path(a: location.name, b: valve.name)
        let travelTime = bestPath[path]!

        let state = process(action: .move(valve, travelTime), state: updatedState, availableValves: updatedAvailableValves, time: time + 1, maxMinutes: maxMinutes)
        if state > bestState {
            bestState = state
        }
    }

    return bestState
}

/*
func process(location: Node, openValves: [Node], availableValves: [Node], minute: Int, totalFlow: Int) -> ([Node], Int) {
    var bestResult: ([Node], Int) = (openValves, totalFlow)

    print("## Minute \(minute), at \(location), openValves: \(openValves), availableValves: \(availableValves), totalFlow \(totalFlow)")

    let currentFlow = openValves.reduce(0, { $0 + $1.rate })
    print("  currentFlow \(currentFlow)")

    if availableValves.isEmpty {
        // Sit idle for the rest of the time
        let remainingTime = maxMinutes - minute
        print("  remaining time \(remainingTime)")
        return (bestResult.0, bestResult.1 + currentFlow * remainingTime)
    }

    // Try each of the possible available valves as the next one to open
    for valveIndex in 0..<availableValves.count {
        let valve = availableValves[valveIndex]
        let path = Path(a: location.name, b: valve.name)
        print("  try \(valve) at distance \(bestPath[path]!)")

        // Travel to the new valve (though we might run out of time)
        let travelTime = min(bestPath[path]!, maxMinutes - minute)
        print("  travel time \(travelTime)")

        var updatedFlow = totalFlow + travelTime * currentFlow

        // If we still have time, spend a minute opening the valve
        var updatedTime = minute + travelTime
        print("  after travel, time \(updatedTime), flow \(updatedFlow)")

        if updatedTime < maxMinutes {
            updatedFlow += currentFlow
            updatedTime += 1
            print("  after opening \(valve), time \(updatedTime), flow \(updatedFlow)")

            var updatedAvailableVales = availableValves
            updatedAvailableVales.remove(at: valveIndex)

            let result = process(location: valve, openValves: openValves + [valve], availableValves: updatedAvailableVales, minute: updatedTime, totalFlow: updatedFlow)
            if result.1 > bestResult.1 {
                bestResult = result
                print("  bestResult \(bestResult)")
            }
        } else {
            // Ran out of time
            if updatedFlow > bestResult.1 {
                bestResult = (openValves, updatedFlow)
                print("  bestResult \(bestResult)")
            }
        }
    }

    return bestResult
}
*/

// We have 15 available valves to start, permutations(15) is 1_307_674_368_000
//for x in nodes.permutations() {
//
//}

//let (path, totalFlow) = process(location: nodeByName["AA"]!, openValves: [], availableValves: availableValves, minute: 1, totalFlow: 0)
//print("path \(path), totalFlow \(totalFlow)")

do {
    let result = process(action: .idle(nodeByName["AA"]!), state: State(openValves: [], pressureReleased: 0), availableValves: availableValves, time: 0, maxMinutes: 30)
    print("result \(result)")
    assert(result.pressureReleased == 2181)
}

do {
    let first = process(action: .idle(nodeByName["AA"]!), state: State(openValves: [], pressureReleased: 0), availableValves: availableValves, time: 0, maxMinutes: 26)
    print("first \(first)")

    let second = process(action: .idle(nodeByName["AA"]!), state: State(openValves: [], pressureReleased: 0), availableValves: availableValves.filter { first.openValves.contains($0) == false }, time: 0, maxMinutes: 26)
    print("second \(second)")
    print("\(first.pressureReleased + second.pressureReleased)")
    assert(first.pressureReleased + second.pressureReleased == 2824)
}
