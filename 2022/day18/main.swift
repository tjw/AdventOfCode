//
//  main.swift
//  day18
//
//  Created by Timothy Wood on 12/22/22.
//

import Foundation

print("Hello, World!")

enum Element {
    case air
    case lava
}
let input = Input.lines().map { Location3D(line: $0) }

do {
    let map = HashMap3D<Element>(defaultElement: .air)
    input.forEach { map[$0] = .lava }

    var surface = 0
    map.forEach { location, element in
        guard element == .lava else { return }
        Location3D.cardinalDirections.forEach {
            if map[location + $0] == .air {
                surface += 1
            }
        }
    }
    print("\(surface)")
    assert(surface == 4604)
}

do {
    let map = HashMap3D<Element>(defaultElement: .air)
    input.forEach { map[$0] = .lava }

    let bounds = map.bounds
    var exteriorReachable = Set<Location3D>()

    // Find all the air locations w/in the bounds that can reach outside the bounds
    var exteriorAir = Set<Location3D>()
    map.forEach { location, element in
        guard element == .air else { return }

        Location3D.cardinalDirections.forEach { dir in
            // Check if the neighbor can traverse orthogonal cells to get to the outside
            var visited = Set<Location3D>()
            var remaining = [location+dir]

            while let next = remaining.first {
                remaining = Array(remaining.dropFirst())

                for dir in Location3D.cardinalDirections {
                    let candidate = next + dir
                    if visited.contains(candidate) { continue } // xxx need to keep track of connected groups that are inside and outside

                    if !bounds.contains(location: next) {
                        // Every visited location can reach the outside, so this location is 'outside'
                    }
                }
            }
        }
    }


    var surface = 0
    map.forEach { location, element in
        guard element == .lava else { return }

        Location3D.cardinalDirections.forEach {
            let neighbor = location + $0
            guard map[neighbor] == .air else { return }

            // Check if the neighbor can traverse orthogonal cells to get to the outside
            var visited = Set<Location3D>()
            var remaining = [neighbor]

            while let candidate = remaining.first {
                remaining = Array(remaining.dropFirst())

                if visited.contains(remaining) {
                    continue
                }

                for dir in Location3D.cardinalDirections {
                    let next = candidate + dir
                    if !bounds.contains(location: next) {
                        // Every visited location can reach the outside, so this location is 'outside'
                    }
                }
            }
        }
    }
}


