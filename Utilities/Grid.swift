//
//  Grid.swift
//  day12
//
//  Created by Timothy Wood on 12/11/22.
//

import Foundation

class Map<Element> {

    let elements: [[Element]]
    let width: Int
    let height: Int

    init(elements: [[Element]]) {
        self.elements = elements
        self.height = elements.count
        self.width = elements[0].count

        elements.forEach { assert($0.count == self.width) }
    }

    subscript(location: Location) -> Element? {
        if location.x < 0 || location.x >= width || location.y < 0 || location.y >= height {
            return nil
        }
        return elements[location.y][location.x]
    }

    func forEach(_ operation: (Location, Element) -> Void) {
        (0..<height).forEach { y in
            (0..<width).forEach { x in
                operation(Location(x: x, y: y), elements[y][x])
            }
        }
    }
}
