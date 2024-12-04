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

    func forEach(_ operation: (Location2D) -> Void) {
        for currentY in y ..< y + height {
            for currentX in x ..< x + width {
                operation(Location2D(x: currentX, y: currentY))
            }
        }
    }
}
