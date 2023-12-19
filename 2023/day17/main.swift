//
//  main.swift
//  day17
//
//  Created by Timothy Wood on 12/17/23.
//

import Foundation

let lines = Array(Input.lines())
let map = GridMap<Int>(lines: lines) { _, ch in Int(String(ch))! }

struct Traversal : Comparable {
    let cost: Int

    struct PathElement : Equatable {
        let location: Location2D
        let direction: Location2D // The direction this was entered from, or zero if this is the start
    }

    let path: [PathElement]

    var location: Location2D {
        path.last!.location
    }

    func pathHasMaximumLengthInDirection(_ dir: Location2D) -> Bool {
        let pathCount = path.count
        guard pathCount >= 3 else { return false }

        // If we already have three steps in the same direction, we can't continue in that direction
        return path[pathCount - 1].direction == dir && path[pathCount - 2].direction == dir && path[pathCount - 3].direction == dir
    }

    static func < (lhs: Traversal, rhs: Traversal) -> Bool {
        lhs.cost < rhs.cost
    }
}


func traverse(map: GridMap<Int>) -> Traversal {
    let start = Traversal(cost: 0, path: [Traversal.PathElement(location: .zero, direction: .zero)])
    let end = Location2D(x: map.width - 1, y: map.height - 1)

    var heap = Heap<Traversal>()
    heap.push(start)

    var bestTraversalForLocation = [Location2D:Traversal]()
    bestTraversalForLocation[start.location] = start

    while true {
        let best = heap.popMin()!
        print("best at \(best.location), cost \(best.cost), with \(heap.count) remaining")

        for dir in Location2D.cardinalDirections {
            guard dir != -best.path.last!.direction else {
                // Can't turn around
                continue
            }

            let next = best.location + dir
            guard let cost = map[next] else { continue }

            if best.pathHasMaximumLengthInDirection(dir) {
                continue
            }

            let nextTraversal = Traversal(cost: best.cost + cost, path: best.path + [Traversal.PathElement(location: next, direction: dir)])
            if nextTraversal.location == end {
                return nextTraversal
            }

            if let previousBest = bestTraversalForLocation[next] {
                if previousBest.cost <= nextTraversal.cost {
                    continue
                } else {
                    print("  better path found")
                }
            }

            bestTraversalForLocation[next] = nextTraversal
            heap.push(nextTraversal)
            print("  insert \(nextTraversal.location), cost \(nextTraversal.cost)")
        }

//        print("heap now:")
//        for item in heap {
//            print("  cost \(item.cost)")
//        }
    }
}

do {
    let traversal = traverse(map: map)
    print("\(traversal.cost)")

    var locationToDirection = [Location2D:Location2D]()
    for element in traversal.path {
        assert(locationToDirection[element.location] == nil)
        locationToDirection[element.location] = element.direction
    }

    map.forEach { location, cost in
        if let direction = locationToDirection[location] {
            switch direction {
            case .up:
                print("v", terminator: "")
            case .down:
                print("^", terminator: "")
            case .left:
                print("<", terminator: "")
            case .right:
                print(">", terminator: "")
            case .zero:
                print(".", terminator: "")
            default:
                fatalError()
            }
        } else {
            print("\(cost)", terminator: "")
        }
        if location.x == map.width - 1 {
            print("")
        }
    }
}
