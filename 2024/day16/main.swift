//
//  main.swift
//  day16
//
//  Created by Timothy Wood on 12/15/24.
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

// 0, 0 on the bottom
let map = GridMap<MapLocation>(lines: Input.lines().reversed()) { loc, ch in
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

struct Heading : Hashable {
    var location: Location2D
    var direction: Location2D
}

class Route {
    var headings: [Heading]
    var score: Int

    // Other routs to this some intermediate result that were another route to this same heading at the same score
    var alternates: [Route]

    init(headings: [Heading], score: Int, alternates: [Route]) {
        self.headings = headings
        self.score = score
        self.alternates = alternates
    }

    var superseded: Bool = false

    var heading: Heading {
        headings.last!
    }

    var location: Location2D {
        headings.last!.location
    }
    var direction: Location2D {
        headings.last!.direction
    }

    var lastMoveWasTurn: Bool {
        let count = headings.count
        if count < 2 {
            return false
        }
        let current = headings[count - 1]
        let previous = headings[count - 2]
        if current.location == previous.location {
            assert(current.direction != previous.direction)
            return true
        }
        return false
    }
}

// TODO: two routes arriving at the same location might be headed different directions so it might be needed somehow to not score a route immediately at a turn but wait for it to commit to the new direction?

let initial = Route(headings: [Heading(location: location, direction: direction)], score: 0, alternates: [])
var heap = Heap(elements: [initial], isBefore: { $0.score < $1.score })

// Keep the best for not get getting to a location, but what direction we were going when we got there.
var bestByHeading = [Heading:Route]()

func printMap(route: Route) {
    var directionByLocation = [Location2D:Location2D]()

    // There will be some overwriting with turns. Whatever, can make it only show forward motion if needed
    for heading in route.headings {
        directionByLocation[heading.location] = heading.direction
    }

    // Printing '<#' with some text and then a closing # followed by > (can't join them here or they'll do it...) makes a placeholder value and drops the quoting characters, messing up the output. (That is the placeholder shows up in the Console.
    // Could maybe use that for kinda highlighting in the console, but will use emoji for now.

    for y in (0..<map.height).reversed() {
        for x in 0..<map.width {
            let loc = Location2D(x: x, y: y)
            if let dir = directionByLocation[loc] {
                switch dir {
                case .left:
                    print("⬅️", terminator: "")
                case .right:
                    print("➡️", terminator: "")
                case .up:
                    print("⬆️", terminator: "")
                case .down:
                    print("⬇️", terminator: "")
                default:
                    fatalError()
                }
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
func printVisited(_ visited: Set<Location2D>) {
    for y in (0..<map.height).reversed() {
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

while true {
    let route = heap.removeFirst()

    if route.location == end {
        print("\(route.score)")
        assert(route.score == 143564)

        printMap(route: route)

        var visited = Set<Location2D>(route.headings.map { $0.location })
        for alternate in route.alternates {
            visited.formUnion(alternate.headings.map { $0.location} )
        }

        // See about others routes that are the same cost
        while !heap.isEmpty {
            let other = heap.removeFirst()
            if other.score > route.score {
                print("other score is \(other.score)")
                break
            } else if other.location == end {
                print("~~~~~~")
                printMap(route: other)

                visited.formUnion(other.headings.map { $0.location })
                for alternate in other.alternates {
                    visited.formUnion(alternate.headings.map { $0.location} )
                }
            }
        }

        print("~~~~~~")
        printVisited(visited)

        print("\(visited.count)")
        assert(visited.count == 593)

        break
    }

    if route.superseded {
        // Skip this one, there is a better route in the heap or one that is equivalent and lists this one in its alternates
        continue
    }

    func addNewRoute(_ route: Route) {
        let heading = route.heading
        if let best = bestByHeading[heading] {
            if best.score > route.score {
                // The new route is better
                best.superseded = true
                bestByHeading[heading] = route
            } else if best.score == route.score {
                // The new route is equivalent. Record the alternate, but do still replace the old one
                best.superseded = true
                bestByHeading[heading] = route
                route.alternates.append(best)
            } else {
                // Existing route is better
                return
            }
        } else {
            bestByHeading[heading] = route
        }
        heap.insert(route)
    }

    // Add new routes extending this one. It only makes sense to add turns if there is an open spot in that direction.

    // See if we can continue straight
    do {
        let next = route.location + route.direction
        let element = map[next]!
        if element == .empty {
            let forwardHeading = Heading(location: next, direction: route.direction)
            let forward = Route(headings: route.headings + [forwardHeading], score: route.score + 1, alternates: route.alternates)
            addNewRoute(forward)
        }
    }

    // See if there paths to the left and right, unless our previous move was a turn. We never want to turn back on a direction or turn left and then right immediately.
    if !route.lastMoveWasTurn {
        let location = route.location
        let direction = route.direction

        let left = direction.turnLeft
        if map[location + left] == .empty {
            let leftHeading = Heading(location: location, direction: left)
            let turn = Route(headings: route.headings + [leftHeading], score: route.score + 1000, alternates: route.alternates)
            addNewRoute(turn)
        }

        let right = direction.turnRight
        if map[location + right] == .empty {
            let rightHeading = Heading(location: location, direction: right)
            let turn = Route(headings: route.headings + [rightHeading], score: route.score + 1000, alternates: route.alternates)
            addNewRoute(turn)
        }
    }

}
