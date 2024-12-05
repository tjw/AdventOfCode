//
//  main.swift
//  day9
//
//  Created by Timothy Wood on 12/4/24.
//

import Foundation

struct Route {
    let location1: String
    let location2: String
    let distance: Int
}

let routes = Input.lines().map { line in
    // Faerun to Tristram = 65
    let items = line.split(separator: " ")
    assert(items.count == 5)
    return Route(location1: String(items[0]), location2: String(items[2]), distance: Int(items[4])!)
}

let locations = Set(routes.flatMap { [$0.location1, $0.location2] }).sorted()
print("locations \(locations)")

// Dijkstra’s Algorithm to find the shortest path for a given starting location that hits all other locations
let locationCount = locations.count

let map = GridMap(element: Int.max, width: locationCount, height: locationCount)
