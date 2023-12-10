//
//  main.swift
//  day8
//
//  Created by Timothy Wood on 12/7/23.
//

import Foundation

let lines = Input.lines()

struct Node {
    let name: String
    let left: String
    let right: String
}

var nodes = [String:Node]()

let directions = lines.first!
for line in lines.dropFirst() {
    guard !line.isEmpty else { continue }

    let match = try! /([A-Z]+) = \(([A-Z]+), ([A-Z]+)\)/.firstMatch(in: line)!
    //print("match \(match)")

    let name = String(match.1)
    let left = String(match.2)
    let right = String(match.3)

    let node = Node(name: name, left: left, right: right)
    nodes[name] = node
}

func traverse(from startingLocation: String, endOnAllZs: Bool) -> Int {
    var location = startingLocation
    var steps = 0
    var nextDirection = directions[...]

    while true {
        if endOnAllZs && location == "ZZZ" {
            break
        } else {
            if location.hasSuffix("Z") {
                break
            }
        }

        if nextDirection.isEmpty {
            nextDirection = directions[...]
        }

        let direction = nextDirection.first!
        nextDirection = nextDirection.dropFirst()

        let node = nodes[location]!
        if direction == "L" {
            location = node.left
        } else {
            location = node.right
        }
        steps += 1
    }

    return steps
}

do {
    let steps = traverse(from: "AAA", endOnAllZs: true)
    print("\(steps)")
    assert(steps == 14681)
}

do {
    let startingLocations: Set<String> = Set(nodes.map(\.key).filter { $0.hasSuffix("A") })

    for startingLocation in startingLocations {
        var location = startingLocation

        var visitedSet = Set<String>()
        var visitedList = [String]()

        var steps = 0
        var nextDirection = directions[...]

        while true {
            // Find the period of visiting the same Z suffixed location. Make sure the last element in the visited array is the Z terminator
            let done = visitedSet.contains(location) && location.hasSuffix("Z")

            visitedSet.insert(location)
            visitedList.append(location)

            if done {
                break
            }

            if nextDirection.isEmpty {
                nextDirection = directions[...]
            }
            let direction = nextDirection.first!
            nextDirection = nextDirection.dropFirst()

            let node = nodes[location]!
            if direction == "L" {
                location = node.left
            } else {
                location = node.right
            }
            steps += 1
        }

        let cycleTerminator = visitedList.last!
        let firstIndex = visitedList.firstIndex(of: cycleTerminator)!
        let cycleLength = visitedList.count - firstIndex

        print("start \(startingLocation), cycleTerminator \(cycleTerminator), firstIndex \(firstIndex), cycleLength \(cycleLength)")
    }

/*
 start AAA, cycleTerminator ZZZ, firstIndex 14681, cycleLength 14682
 start BXA, cycleTerminator PMZ, firstIndex 13019, cycleLength 13020
 start QNA, cycleTerminator NPZ, firstIndex 16343, cycleLength 16344
 start MTA, cycleTerminator BJZ, firstIndex 16897, cycleLength 16898
 start XCA, cycleTerminator PBZ, firstIndex 21883, cycleLength 21884
 start VCA, cycleTerminator BLZ, firstIndex 20221, cycleLength 20222
 */

    // Took a stab and used an online LCM calculator to find 14321394058031
}
