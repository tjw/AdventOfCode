//
//  main.swift
//  day12
//
//  Created by Timothy Wood on 12/11/24.
//

import Foundation

let map = GridMap<Character>(lines: Input.lines().reversed()) { loc, ch in ch }

class Region {
    let type: Character
    var plots: Set<Location2D>

    init(type: Character, location: Location2D) {
        self.type = type
        self.plots = [location]
    }

    var area: Int {
        return plots.count
    }

    var perimiter: Int {
        var total = 0
        plots.forEach { loc in
            for dir in Location2D.cardinalDirections {
                if map[loc + dir] != type {
                    total += 1
                }
            }
        }
        return total
    }
}

var regions = [Region]()

do {
    var seen = Set<Location2D>()

    map.forEach { loc, ch in
        if seen.contains(loc) {
            return // already in another region
        }

        seen.insert(loc)

        let region = Region(type: ch, location: loc)
        //print("New region of \(ch) at \(loc)")

        var flood = [loc]
        while !flood.isEmpty {
            let last = flood.last!
            //print("  flood from \(last)")
            flood.removeLast()
            assert(seen.contains(last))

            for dir in Location2D.cardinalDirections {
                let candidate = last + dir
                if !seen.contains(candidate) && map.contains(location: candidate) && map[candidate] == ch {
                    //print("  add \(candidate)")
                    region.plots.insert(candidate)
                    seen.insert(candidate)
                    flood.append(candidate)
                }
            }
        }

        regions.append(region)
    }
}

do {

    //regions.sort { $0.type < $1.type }
    var total = 0
    regions.forEach { region in
        print("\(region.type) \(region.area) \(region.perimiter)")
        total += region.area * region.perimiter
    }
    print("\(total)")
//    assert(total == 1387004)
}


do {
    // sketch... find the top-most/left-most plot in the region to use as the starting point. start out heading east and trace the shape using left hand turns. somehow find any regions totally surrounded by this region and add their perimiter
}
