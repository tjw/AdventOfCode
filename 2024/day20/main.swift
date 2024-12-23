//
//  main.swift
//  day20
//
//  Created by Timothy Wood on 12/19/24.
//

import Foundation

enum MapLocation : Character {
    case empty = "."
    case wall = "#"
}

var location = Location2D(x: 1, y: 1)
var direction = Location2D.right
var start = Location2D.zero
var end = Location2D.zero

let map = GridMap<MapLocation>(lines: Input.lines()) { loc, ch in
    if ch == "S" {
        start = loc
        return .empty
    }
    if ch == "E" {
        end = loc
        return .empty
    }
    return MapLocation(rawValue: ch)!
}
print("Start \(start)")
print("End \(end)")

// Each route is the end of a chain (to avoid copying the entire path around).
class Route {
    let previous: Route?
    let location: Location2D
    let steps: Int

    var superseded: Bool = false

    init(previous: Route?, location: Location2D) {
        self.previous = previous
        self.location = location

        // Don't count the initial position as a step
        if let previous = previous {
            self.steps = previous.steps + 1
        } else {
            self.steps = 0
        }
    }

    var allLocations: [Location2D] {
        var locations = [Location2D]()
        var route = self

        while true {
            locations.append(route.location)
            if let previous = route.previous {
                route = previous
            } else {
                return locations.reversed()
            }
        }
    }
}

func printMap(route: Route, cheat: Location2D? = nil, better: Route? = nil) {
    let visited = Set(route.allLocations)
    let betterVisitied = Set(better?.allLocations ?? [])

    for y in (0..<map.height) {
        for x in 0..<map.width {
            let loc = Location2D(x: x, y: y)
            if loc == cheat {
                print("❎", terminator: "")
            } else if betterVisitied.contains(loc) {
                print("🟢", terminator: "")
            } else if visited.contains(loc) {
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

func findBestRoute(from start: Location2D, to end: Location2D) -> Route? {
    let initial = Route(previous: nil, location: start)
    var heap = Heap(elements: [initial], isBefore: { $0.steps < $1.steps })
    var bestByLocation = [Location2D:Route]()

    //printMap(route: initial)

    while true {
        if heap.isEmpty {
            print("No route")
            return nil
        }
        let route = heap.removeFirst()

        if route.location == end {
            return route
        }

        if route.superseded {
            continue
        }

        func addNewRoute(base: Route, direction: Location2D) {
            let candidate = base.location + direction

            guard let element = map[candidate] else { return }
            guard element == .empty else { return }

            let route = Route(previous: base, location: candidate)

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

let startTime = Date.timeIntervalSinceReferenceDate

guard let route = findBestRoute(from: start, to: end) else {
    print("No route")
    exit(0)
}

printMap(route: route)

var cheatsBySavings = [Int:[Location2D]]()

var attemptedCheats = Set<Location2D>()

var count = 0

var originalRouteLocations = route.allLocations
print("Original picos \(originalRouteLocations.count)")

for pico in 0..<originalRouteLocations.count - 1 {

    if pico % 100 == 0 {
        print("... \(pico)")
    }

    let current = originalRouteLocations[pico]

    for dir1 in Location2D.cardinalDirections {
        // Find all adjacent walls
        let candidate1 = current + dir1
        if map[candidate1] != .wall {
            continue
        }
        for dir2 in Location2D.cardinalDirections {
            if dir2 == -dir1 {
                continue
            }
            let candidate2 = candidate1 + dir2
            if map[candidate2] != .empty {
                continue
            }

            let cheat = candidate1
            if attemptedCheats.contains(cheat) {
                continue
            }
            attemptedCheats.insert(cheat)


            // Try this cheat
            map[cheat] = .empty

            // Make a new route to the end from the current spot, given the modified map. Has to be a route since the map is *more* permissive than it was
            let candidate = findBestRoute(from: current, to: end)!

            if pico + candidate.steps < route.steps {
                //print("Better: \(pico + candidate.steps) ")
                //printMap(route: route, cheat0: loc0, cheat1: loc1, cheat2: loc2, better: candidate)

                let savings = route.steps - (pico + candidate.steps)
                if savings >= 100 {
                    print("\(cheat)")
                    count += 1
                    //printMap(route: route, cheat: cheat, better: candidate)
                }
                cheatsBySavings[savings] = (cheatsBySavings[savings] ?? []) + [cheat]
            }

            // Restore the map
            map[cheat] = .wall
        }
    }
}

cheatsBySavings.keys.sorted().forEach { key in
    print("\(cheatsBySavings[key]!.count) that save \(key)")
}

print("\(count)")
assert(count == 1197)

let endTime = Date.timeIntervalSinceReferenceDate
print("duraction \(endTime - startTime)")
