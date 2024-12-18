//
//  main.swift
//  day18
//
//  Created by Timothy Wood on 12/17/24.
//

import Foundation

enum MapElement: Character {
    case empty = "."
    case wall = "#"
}

class Route {
    var locations: [Location2D]

    var superseded: Bool = false

    init(locations: [Location2D]) {
        self.locations = locations
    }

    var location: Location2D {
        return locations.last!
    }

    var steps: Int {
        // Don't count the initial position as a step
        return locations.count - 1
    }
}

let byteLocations: [Location2D] = Input.lines().map { line in
    let pair = line.numbers(separatedBy: ",")
    return Location2D(x: pair[0], y: pair[1])
}

let size = 71

func pathLengthAfterByteCount(_ byteCount: Int) -> Int? {
    let map = GridMap<MapElement>(element: .empty, width: size, height: size)
    byteLocations[0..<byteCount].forEach { loc in
        map[loc] = .wall
    }


    let initial = Route(locations: [.zero])
    let end = Location2D(x: size - 1, y: size - 1)

    var heap = Heap(elements: [initial], isBefore: { $0.steps < $1.steps })
    var bestByLocation = [Location2D:Route]()

    func printMap(route: Route) {
        let visited = Set(route.locations)

        for y in (0..<map.height) {
            for x in 0..<map.width {
                let loc = Location2D(x: x, y: y)
                if visited.contains(loc) {
                    print("🟠", terminator: "")
                } else {
                    let element = map[loc]!
                    switch element {
                    case .empty:
                        print("⬜️", terminator: "")
                    case .wall:
                        print("🟫", terminator: "")
                    }
                }
            }
            print("")
        }
    }

    printMap(route: initial)

    while true {
        if heap.isEmpty {
            print("No route")
            return nil
        }
        let route = heap.removeFirst()

        if route.location == end {
            print("\(route.steps)")
            //assert(route.score == 143564)

            printMap(route: route)
            return route.steps
        }

        if route.superseded {
            continue
        }

        func addNewRoute(base: Route, direction: Location2D) {
            let candidate = base.location + direction

            guard let element = map[candidate] else { return }
            guard element == .empty else { return }

            let route = Route(locations: base.locations + [candidate])

            if let best = bestByLocation[candidate] {
                if best.steps > route.steps {
                    // The new route is better
                    best.superseded = true
                    bestByLocation[candidate] = route
                } else {
                    // Existing route is better or just as good
                    return
                }
            } else {
                bestByLocation[candidate] = route
            }
            heap.insert(route)
        }

        // Add new routes extending this one. It only makes sense to add turns if there is an open spot in that direction.
        for dir in Location2D.cardinalDirections {
            addNewRoute(base: route, direction: dir)
        }
    }
}

//do {
//    let result = pathLengthAfterByteCount(1024)
//    assert(result == 374)
//}

do {
    let totalBytes = byteLocations.count

    var lower = 0
    var upper = totalBytes

    while lower + 1 < upper {
        let attempt = (lower + upper) / 2
        if let length = pathLengthAfterByteCount(attempt) {
            print("\(attempt) -> \(length)")
            lower = attempt
        } else {
            upper = attempt
            print("\(attempt) -- no path")
        }
    }

    print("lower \(lower) -- \(byteLocations[lower].x),\(byteLocations[lower].y)")
    assert(lower == 2911)
    assert(byteLocations[lower] == Location2D(x: 30, y: 12))
}
