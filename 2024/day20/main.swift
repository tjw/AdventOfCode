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

func printMap(route: Route, cheat: Location2D? = nil, better: Route? = nil) {
    let visited = Set(route.locations)
    let betterVisitied = Set(better?.locations ?? [])

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
    let initial = Route(locations: [start])
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

guard let route = findBestRoute(from: start, to: end) else {
    print("No route")
    exit(0)
}

printMap(route: route)

// Try each possible cheat location along the original best path and then see if we can make a better path

// Each cheat is three locations. The first one must be a wall. The second may be a wall or empty, and the third must be empty (if used, which it isn't if second is empty). That is, a cheat only needs to be one wall.

func combinations(_ dir1: Location2D, _ dir2: Location2D) -> [[Location2D]] {
    var result: [[Location2D]] = []

    for i in 0..<8 {
        // Make the output be the cummulative offset from the start
        let offset1 = ((i & 1) == 0) ? dir1 : dir2
        let offset2 = ((i & 2) == 0) ? dir1 : dir2
        let offset3 = ((i & 4) == 0) ? dir1 : dir2

        result.append([
            offset1,
            offset1 + offset2,
            offset1 + offset2 + offset3
        ])
    }

    return result
}

let cheatOffsets: [[Location2D]] = combinations(.up, .right) + combinations(.up, .left) + combinations(.down, .right) + combinations(.down, .left)

var cheatsBySavings = [Int:[Location2D]]()

var attemptedCheats = Set<Location2D>()

for pico in 0..<route.locations.count - 1 {

    let current = route.locations[pico]

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

            // Require the new route to have taken the give path
            assert(candidate.locations[0] == current)
//            if candidate.locations.count < 2 || candidate.locations[1] != cheat.start {
//                continue
//            }

            if pico + candidate.steps < route.steps {
                //print("Better: \(pico + candidate.steps) ")
                //printMap(route: route, cheat0: loc0, cheat1: loc1, cheat2: loc2, better: candidate)

                let savings = route.steps - (pico + candidate.steps)
                if savings == 2 {
                    print("cheat \(cheat)")
                    printMap(route: route, cheat: cheat, better: candidate)
                }
                cheatsBySavings[savings] = (cheatsBySavings[savings] ?? []) + [cheat]
            }

            // Restore the map
            map[cheat] = .wall
        }
    }

    /*
    for cheatOffset in cheatOffsets {
        // Make sure at least two of the cheat steps are on the map and store the original values
        let loc0 = current + cheatOffset[0]
        let loc1 = current + cheatOffset[1]
        let loc2 = current + cheatOffset[2]


        guard let cheat0 = map[loc0], let cheat1 = map[loc1] else { continue }
        let cheat2 = map[loc2]

        // First must be a wall.
        guard cheat0 == .wall else { continue }

        // Then either an empty or a wall and an empty
        guard cheat1 == .empty || cheat2 == .empty else {
            continue
        }

        // A cheat that doesn't actually end up using the second location is unique to any other with the same first location
        let cheat = Cheat(cheat0: loc0, cheat1: cheat1 == .empty ? nil : loc1)
        if attemptedCheats.contains(cheat) {
            continue
        }
        attemptedCheats.insert(cheat)

        // Try this cheat
        map[loc0] = .empty
        map[loc1] = .empty

        // Make a new route to the end from the current spot, given the modified map. Has to be a route since the map is *more* permissive than it was
        let candidate = findBestRoute(from: current, to: end)!
        assert(candidate.locations[0] == current)


        if pico + candidate.steps < route.steps {
            //print("Better: \(pico + candidate.steps) ")
            //printMap(route: route, cheat0: loc0, cheat1: loc1, cheat2: loc2, better: candidate)

            let savings = route.steps - (pico + candidate.steps)
            if savings == 64 {
                print("loc0 \(loc0), loc1 \(loc1), loc2 \(loc2)")
                print("success \(cheat)")
                printMap(route: route, cheat0: loc0, cheat1: loc1, cheat2: loc2, better: candidate)
            }
            cheatsBySavings[savings] = (cheatsBySavings[savings] ?? []) + [cheat]
        }

        // Restore the map
        map[loc0] = cheat0
        if cheat1 == .wall {
            map[loc1] = cheat1
        }
    }
     */
}

cheatsBySavings.keys.sorted().forEach { key in
    print("\(cheatsBySavings[key]!.count) that save \(key)")
}
