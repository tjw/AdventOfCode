//
//  main.swift
//  day16
//
//  Created by Timothy Wood on 12/15/23.
//

import Foundation

let lines = Array(Input.lines())

enum TileType : GridCharacter, Hashable {
    case empty
    case verticalSplitter
    case horizontalSplitter
    case forwardSlash
    case backslash

    init(character: Character) {
        switch character {
        case ".":
            self = .empty
        case "|":
            self = .verticalSplitter
        case "-":
            self = .horizontalSplitter
        case "/":
            self = .forwardSlash
        case "\\":
            self = .backslash
        default:
            fatalError()
        }
    }

    var character: Character {
        switch self {
        case .empty:
            "."
        case .verticalSplitter:
            "|"
        case .horizontalSplitter:
            "-"
        case .forwardSlash:
            "/"
        case .backslash:
            "\\"
        }
    }
}

let map = GridMap(lines: lines) { _, ch in TileType(character: ch) }
print(map.stringRepresentation)

@MainActor
struct Beam : Hashable {
    let position: Location2D
    let direction: Location2D

    func step() -> [Beam] {
        let newPosition = position + direction
        guard map.contains(location: newPosition) else {
            return [] // Off the map, beam is done
        }

        let tile = map[newPosition]!

        switch tile {
        case .empty:
            return [Beam(position: newPosition, direction: direction)]
        case .verticalSplitter:
            if direction == .up || direction == .down {
                // Pass through
                return [Beam(position: newPosition, direction: direction)]
            } else {
                // Split up and down
                return [Beam(position: newPosition, direction: .up),
                        Beam(position: newPosition, direction: .down)]
            }
        case .horizontalSplitter:
            if direction == .left || direction == .right {
                // Pass through
                return [Beam(position: newPosition, direction: direction)]
            } else {
                // Split left and right
                return [Beam(position: newPosition, direction: .left),
                        Beam(position: newPosition, direction: .right)]
            }
        case .forwardSlash:
            //
            var newDirection: Location2D
            switch direction {
            case .up:
                newDirection = .left
            case .down:
                newDirection = .right
            case .left:
                newDirection = .up
            case .right:
                newDirection = .down
            default:
                fatalError()
            }
            return [Beam(position: newPosition, direction: newDirection)]
        case .backslash:
            var newDirection: Location2D
            switch direction {
            case .up:
                newDirection = .right
            case .down:
                newDirection = .left
            case .left:
                newDirection = .down
            case .right:
                newDirection = .up
            default:
                fatalError()
            }
            return [Beam(position: newPosition, direction: newDirection)]
        }
    }
}

@MainActor
func energizedCount(from startingBeam: Beam) -> Int {
    var beams = [startingBeam]

    // If we have a beam in the same location and direction, it will produce the same results as any previous such beam
    var seenBeems = Set<Beam>()

    var energized = Set<Location2D>() // NOT including the starting location since it's outside the map

    var count = 0
    while !beams.isEmpty {
        beams = beams.flatMap({ $0.step() }).filter({ !seenBeems.contains($0) })
        seenBeems.formUnion(beams)
        energized.formUnion(beams.map(\.position))
        count += 1

//        print("\(count): \(beams.count) beams")
//        map.forEach { location, _ in
//            if energized.contains(location) {
//                print("#", terminator: "")
//            } else {
//                print(".", terminator: "")
//            }
//            if location.x == map.width - 1 {
//                print("")
//            }
//        }
//        print("")
    }

//    print("\(energized.count)")
    return energized.count
}

do {
    let beam = Beam(position: Location2D(x: -1, y: 0), // Start outside the map,
                    direction: .right)
    let count = energizedCount(from: beam)
    print("\(count)")
    assert(count == 7623)
}

do {
    var bestCount = 0

    for y in 0..<map.height {
        let leftEdge = Beam(position: Location2D(x: -1, y: y), // Start outside the map,
                            direction: .right)
        bestCount = max(bestCount, energizedCount(from: leftEdge))

        let rightEdge = Beam(position: Location2D(x: map.width, y: y), // Start outside the map,
                             direction: .left)
        bestCount = max(bestCount, energizedCount(from: rightEdge))
    }

    for x in 0..<map.width {
        let topEdge = Beam(position: Location2D(x: x, y: -1), // Start outside the map,
                           direction: .up)
        bestCount = max(bestCount, energizedCount(from: topEdge))

        let bottomEdge = Beam(position: Location2D(x: x, y: map.height), // Start outside the map,
                             direction: .down)
        bestCount = max(bestCount, energizedCount(from: bottomEdge))
    }

    print("\(bestCount)")
    assert(bestCount == 8244)
}
