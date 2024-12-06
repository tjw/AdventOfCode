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

    struct PathElement : Equatable {
        let location: Location2D
        let direction: Location2D // The direction this was entered from, or zero if this is the start
    }

    init(start: Location2D) {
        self.cost = 0
        self.path = [Traversal.PathElement(location: start, direction: .zero)]
    }

    private init(cost: Int, path: [PathElement]) {
        self.cost = cost
        self.path = path
    }

    let cost: Int
    let path: [PathElement]

    var location: Location2D {
        path.last!.location
    }

    func moveInDirection(_ dir: Location2D, map: GridMap<Int>) -> Traversal? {
        let location = self.location
        let next = location + dir

        guard let nextCost = map[next] else {
            return nil
        }

        let candidate = Traversal(cost: cost + nextCost, path: path + [PathElement(location: next, direction: dir)])
        if candidate.straightLinePathLength > 3 {
            return nil
        }

        return candidate
    }

//    func pathHasMaximumLengthInDirection(_ dir: Location2D) -> Bool {
//        let pathCount = path.count
//        guard pathCount >= 3 else { return false }
//
//        // If we already have three steps in the same direction, we can't continue in that direction
//        return path[pathCount - 1].direction == dir && path[pathCount - 2].direction == dir && path[pathCount - 3].direction == dir
//    }

    var straightLinePathLength: Int {
        let pathCount = path.count
        assert(pathCount >= 1) // init(start:) adds at least one element

        if pathCount < 2 {
            return pathCount - 1
        }

        var length = 1
        let dir = path.last!.direction

        for element in path.dropLast().reversed() {
            if element.direction == dir {
                length += 1
            } else {
                return length
            }
        }

        fatalError() // The first shoud have direction (0,0) and no others should
    }

    static func < (lhs: Traversal, rhs: Traversal) -> Bool {
        lhs.cost < rhs.cost
    }
}


func traverse(map: GridMap<Int>) -> Traversal {
    let start = Traversal(start: .zero)
    let end = Location2D(x: map.width - 1, y: map.height - 1)

    var heap = MinMaxHeap<Traversal>()
    heap.push(start)

    var bestTraversalForLocation = [Location2D:Traversal]()
    bestTraversalForLocation[start.location] = start

    while true {
        guard let best = heap.popMin() else {
            return bestTraversalForLocation[end]!
        }
        print("best at \(best.location), cost \(best.cost), with \(heap.count) remaining")

        for dir in Location2D.cardinalDirections {
            guard dir != -best.path.last!.direction else {
                // Can't turn around
                print("  skip dir \(dir), which is backwards")
                continue
            }

            guard let nextTraversal = best.moveInDirection(dir, map: map) else {
                continue
            }

//            if nextTraversal.location == end {
//                return nextTraversal
//            }

            if let previousBest = bestTraversalForLocation[nextTraversal.location] {
                if previousBest.cost < nextTraversal.cost {
                    // Keep the existing traversal for this location
                    print("  \(nextTraversal.location) alreaady reached with cost \(previousBest.cost) compared to \(nextTraversal.cost)")
                } else {
                    // In the case of the cost being equal, try this traversal too. It might work out better/worse than the original since they have different directions and thus limits on how far they can continue
                    bestTraversalForLocation[nextTraversal.location] = nextTraversal
                    heap.push(nextTraversal)
                    print("  update best cost for \(nextTraversal.location) to \(nextTraversal.cost)")
                }
            } else {
                bestTraversalForLocation[nextTraversal.location] = nextTraversal
                heap.push(nextTraversal)
                print("  insert \(nextTraversal.location), cost \(nextTraversal.cost)")
            }
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
