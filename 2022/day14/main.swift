//
//  main.swift
//  day14
//
//  Created by Timothy Wood on 12/14/22.
//

import Foundation

let input:[[(Int,Int)]] = Input.lines().map { line in
    line.components(separatedBy: "->").map { item in
        let components = item.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        return (Int(components[0])!, Int(components[1])!)
    }
}
//print(input)


// Increasing Y is down in the input, so our sand flows up

enum Content: Character {
    case air  = "."
    case sand = "o"
    case rock = "#"
    case dropping = "+"
}

// Part 1
do {
    // We don't know the actual width/height up front so we'll start at zero by zero and increase as needed
    let map = GridMap<Content>(elements:[[]])

    for var line in input {
        var location = Location(pair: line.first!)
        line = Array(line.dropFirst())
        map.expandToInclude(location: location, content: .air)
        map[location] = .rock

        while !line.isEmpty {
            let destination = Location(pair: line.first!)
            line = Array(line.dropFirst())
            map.expandToInclude(location: destination, content: .air)

            // should be straight lines
            assert(location.x == destination.x || location.y == destination.y)

            let direction: Location
            if location.x > destination.x {
                direction = .left
            } else if location.x < destination.x {
                direction = .right
            } else if location.y > destination.y {
                direction = .down
            } else if location.y < destination.y {
                direction = .up
            } else {
                fatalError()
            }

            while location != destination {
                location += direction
                map[location] = .rock
            }
        }
    }

    var imageCounter: Int = 0

    func writeMapImage() {
        map.writeImage(prefix: "day14.1", number: imageCounter, flipped: false) { content in
            switch content {
            case .air:
                return RGB(r: 255, g: 255, b: 255)
            case .sand:
                return RGB(r: 255, g: 255, b: 0)
            case .rock:
                return RGB(r: 0, g: 0, b: 0)
            case .dropping:
                return RGB(r: 0, g: 255, b: 0)
            }
        }
        imageCounter += 1
    }

falling_to_void:
    while true {
        var dropping = Location(x: 500, y: 0)

        if map[dropping]! != .air {
            break
        }
        map[dropping] = .dropping

        while true {
            let candidates: [Location] = [dropping + .up, dropping + .up + .left, dropping + .up + .right].filter { map.contains(location: $0) }
            guard !candidates.isEmpty else {
                // All the candidates are off the map and the grain will fall into the void
                break falling_to_void
            }

            guard let next = candidates.first(where: { map[$0] == .air }) else {
                map[dropping] = .sand
                writeMapImage()
                break
            }

            map[dropping] = .air
            map[next] = .dropping
            dropping = next
        }
    }

    var grains = 0
    map.forEach { location, content in
        if content == .sand {
            grains += 1
        }
    }
    print("grains \(grains)")
    assert(grains == 795)
}

// MARK: Part 2

do {
    let map = HashMap<Content>(defaultElement: .air)

    for var line in input {
        var location = Location(pair: line.first!)
        line = Array(line.dropFirst())
        map[location] = .rock

        while !line.isEmpty {
            let destination = Location(pair: line.first!)
            line = Array(line.dropFirst())

            // should be straight lines
            assert(location.x == destination.x || location.y == destination.y)

            let direction: Location
            if location.x > destination.x {
                direction = .left
            } else if location.x < destination.x {
                direction = .right
            } else if location.y > destination.y {
                direction = .down
            } else if location.y < destination.y {
                direction = .up
            } else {
                fatalError()
            }

            while location != destination {
                location += direction
                map[location] = .rock
            }
        }
    }

    let floor = map.bounds.y + map.bounds.height + 1
    print("floor \(floor)")
    var imageCounter: Int = 0

    func writeMapImage() {
        map.writeImage(prefix: "day14.2", number: imageCounter, flipped: false) { content in
            switch content {
            case .air:
                return RGB(r: 255, g: 255, b: 255)
            case .sand:
                return RGB(r: 255, g: 255, b: 0)
            case .rock:
                return RGB(r: 0, g: 0, b: 0)
            case .dropping:
                return RGB(r: 0, g: 255, b: 0)
            }
        }
        imageCounter += 1
    }

    while true {
        var dropping = Location(x: 500, y: 0)

        if map[dropping] != .air {
            break
        }
        map[dropping] = .dropping

        while true {
            if dropping.y >= floor - 1 {
                map[dropping] = .sand
                //writeMapImage()
                break
            }

            let candidates: [Location] = [dropping + .up, dropping + .up + .left, dropping + .up + .right]

            guard let next = candidates.first(where: { map[$0] == .air }) else {
                map[dropping] = .sand
                //writeMapImage()
                break
            }

            map[dropping] = .air
            map[next] = .dropping
            dropping = next
        }
    }

    var grains = 0
    map.forEach { location, content in
        if content == .sand {
            grains += 1
        }
    }
    print("grains \(grains)")
    assert(grains == 30214)

}
