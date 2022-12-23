//
//  HashMap3D.swift
//  day18
//
//  Created by Timothy Wood on 12/22/22.
//

import Foundation

class HashMap3D<Element> {

    typealias Location = Location3D
    typealias Bounds = Bounds3D

    private(set) var elements: [Location:Element]

    let defaultElement: Element

    init(defaultElement: Element) {
        self.elements = [:]
        self.defaultElement = defaultElement
    }

    subscript(location: Location) -> Element {
        get {
            return elements[location] ?? defaultElement
        }
        set {
            elements[location] = newValue
        }
    }

    func clear(location: Location) {
        elements.removeValue(forKey: location)
    }

    var bounds: Bounds {
        guard !elements.isEmpty else { return Bounds(x: 0, y: 0, z: 0, width: 0, height: 0, depth: 0) }

        var minLocation = elements.first!.key
        var maxLocation = minLocation

        elements.forEach { location, _ in
            minLocation.x = min(minLocation.x, location.x)
            minLocation.y = min(minLocation.y, location.y)
            minLocation.z = min(minLocation.z, location.z)

            maxLocation.x = max(maxLocation.x, location.x)
            maxLocation.y = max(maxLocation.y, location.y)
            maxLocation.z = max(maxLocation.z, location.z)
        }

        return Bounds(x: minLocation.x,
                      y: minLocation.y,
                      z: minLocation.z,
                      width: maxLocation.x - minLocation.x + 1,
                      height: maxLocation.y - minLocation.y + 1,
                      depth: maxLocation.z - minLocation.z + 1)
    }

    // Compute the bounds of the map and then call the given operation on each location inside that bounds
    func forEach(_ operation: (Location, Element) -> Void) {
        let bounds = self.bounds
        for z in (bounds.z..<bounds.z+bounds.depth) {
            for y in (bounds.y..<bounds.y+bounds.height) {
                for x in (bounds.x..<bounds.x+bounds.width) {
                    let location = Location(x: x, y: y, z: z)
                    operation(location, elements[location] ?? defaultElement)
                }
            }
        }
    }

}
