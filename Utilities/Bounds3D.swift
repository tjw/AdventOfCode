//
//  Bounds3D.swift
//  day18
//
//  Created by Timothy Wood on 12/22/22.
//

import Foundation

struct Bounds3D {
    var x: Int
    var y: Int
    var z: Int
    var width: Int
    var height: Int
    var depth: Int

    func contains(location: Location3D) -> Bool {
        return x <= location.x &&
        x + width >= location.x &&
        y <= location.y &&
        y + height >= location.y &&
        z <= location.z &&
        z + depth >= location.z
    }
}
