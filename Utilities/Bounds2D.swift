//
//  Bounds.swift
//  day14
//
//  Created by Timothy Wood on 12/15/22.
//

import Foundation

struct Bounds2D {
    var x: Int
    var y: Int
    var width: Int
    var height: Int

    init(x: Int, y: Int, width: Int, height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    init(locations: [Location2D]) {
        assert(!locations.isEmpty)

        var minX = locations.first!.x
        var minY = locations.first!.y
        var maxX = minX
        var maxY = minY

        for loc in locations {
            minX = min(minX, loc.x)
            maxX = max(maxX, loc.x)
            minY = min(minY, loc.y)
            maxY = max(maxY, loc.y)
        }

        self.x = minX
        self.y = minY
        self.width = maxX - minX + 1
        self.height = maxY - minY + 1
    }

    func forEach(_ operation: (Location2D) -> Void) {
        for currentY in y ..< y + height {
            for currentX in x ..< x + width {
                operation(Location2D(x: currentX, y: currentY))
            }
        }
    }
}
