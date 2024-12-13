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
    let plots: Set<Location2D>
    let bounds: Bounds2D
    let touchesEdge: Bool

    init(type: Character, plots: [Location2D]) {
        assert(!plots.isEmpty)

        self.type = type
        self.plots = Set(plots)
        self.bounds = Bounds2D(locations: plots)

        // Could maybe extract this to be an operation with two Bounds2D structs
        self.touchesEdge = bounds.x == 0 || bounds.y == 0 || bounds.x + bounds.width >= map.width || bounds.y + bounds.height >= map.height
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

    private(set) var directNeighbors = [Region]()
    func addDirectNeighbor(_ region: Region) {
        assert(!directNeighbors.contains(where: {$0 === region}))
        directNeighbors.append(region)
    }
}

var regions = [Region]()

// Build the regions
do {
    var seen = Set<Location2D>()

    map.forEach { loc, ch in
        if seen.contains(loc) {
            return // already in another region
        }

        let plots = map.flood(from: loc)
        let ch = map[loc]!

        let region = Region(type: ch, plots: plots)
        //print("New region of \(ch) at \(loc)")

        regions.append(region)
        seen.formUnion(plots)
    }

    print("\(regions.count) regions found")
}

// Part 1
do {
    var total = 0
    regions.forEach { region in
        print("\(region.type) \(region.area) \(region.perimiter)")
        total += region.area * region.perimiter
    }
    print("\(total)")
//    assert(total == 1387004)
}


do {
    // Build a map of location to region
    var locationToRegion = [Location2D:Region]()
    for region in regions {
        for loc in region.plots {
            locationToRegion[loc] = region
        }
    }

    for region in regions {
        if region.touchesEdge {
            print("Region \(region.type) touches edge")
        } else {
            print("Region \(region.type) does NOT touch edge")
        }
    }

    // Populate the direct neighbors of each region. One way to model this might be to replace touchesEdge with a psuedo region imagined to be infinitely big around the entire map. Since there will be other cases where one region completely encloses another and algorithms we write for detecting that might also natually produce a correct result for the map edge by doing so. But for now, we have a separate flag
    func regionsAreTouching(_ region1: Region, _ region2: Region) -> Bool {
        for plot in region1.plots {
            for dir in Location2D.cardinalDirections {
                if locationToRegion[plot+dir] === region2 {
                    return true
                }
            }
        }
        return false
    }

    /*

     NOTE: There is a bunch of arguing following here with some steps toward implement what would have looked like:

     - Find all the directly touching neighboring regions.
     - For every pair of neighboring regions, try to find if one completely surrounds the other, so it isn't possible to build a transitive neighbor path to the edge of the map
     - For each region, sort its locations by x and then y or whatever and find location that is the least x and then least y possible among those with the same x (should be a corner)
       - drive a path around the shape keeping track of the number of turns
       - For each inner region find the transitively touching enclosed regions and trace a path around them to add inner corners/sides

     Towards the end is a much simpler corner counting approach.

     */

    // Could speed this up by first checking if their bounds overlap or touch at all. Could also sort regions by Y and keep a running band of possible overlaps.
//    print("Finding direct neighbors")
//    for regionIndex1 in 0..<regions.count-1 {
//        let region1 = regions[regionIndex1]
//        for region2 in regions[regionIndex1+1..<regions.count] {
//            if regionsAreTouching(region1, region2) {
//                region1.addDirectNeighbor(region2)
//                region2.addDirectNeighbor(region1)
//                //print("Regions \(region1.type) and \(region2.type) are direct neighbors")
//            }
//        }
//    }

    /*
     Find regions that are directly and completely contained in another region. That is the two regions are touching and the inner region doesn't have a path of connections that can reach the edge of the map. Regions on the edge of the map cannot be directly contained since the have at least one escaping edge.

     Here X directly contains A and B

     XXXX
     XABX
     XXXX

     Here X directly contains A, but not B. A directly contains B.

     XXXXX
     XAAAX
     XABAX
     XAAAX
     XXXXX

     */

    // Could maybe make this faster with bounds checks or maybe having each region track the minimal number of steps it is from the map edge and then use a Heap to take the most likely quick path first.
//    for region in regions {
//        for neighbor in region.directNeighbors {
//
//        }
//    }

    // Find regions that are totally enclosed in other regions. That is their entire outer perimiter neighbors a single other region.
    /*
     Actually that doesn't work. Consider

     XXXX
     XABX
     XXXX

     A and B are totally contained, but the rule above wouldn't determine this. But could maybe make an unregistered pseudo region that is flooded with "anything not X".

     Could maybe give each region a Bounds2D struct and then one region's bounds is completely inside another (to more quickly reject non-overlapping regiongs). If that passes, then if also for every plot in the maybe-inner region (or just the outer perimiter plots) cast rays out in the cardinal directions. If ... nah. This one wouldn't work:

     XXXXXXXXX
     XXAABBBXX
     XXXXCCCCC

     A would look like it was completely inside X. Could maybe see which regions are adjacent to the outer permiter while tracing it and exclude those.

     I suppose a horrible approach would be to follow up the ray casting with a flood fill to see if we can reach the edge of the map.

     AH! Best would be to keep track of the regions that are on the edge of the map and then propagate that to their neighbors. Regions that are nested to whatever depth inside another region will not be marked as being able to transitively touch the edge.

     This would still need some work maybe? Or maybe this would fall out naturally:

     XXXXXX
     XAAAAX
     XABBAX
     XAAAAX
     XXXXXX


     X would have a direct neighbor A which couldn't reach the edge, but B would *also* have a direct neighbor A that can't reach the edge, but B doesn't encompass A. The bounds check would account for this though.

     *** Would probably need to make the 'contains' check be whether A can tough the edge by going through transitively connected regions *except* for X.

     Alternatively, could sort the plots by Y and then X and march the spans up the region.


     */
    // sketch... find the top-most/left-most plot in the region to use as the starting point. start out heading east and trace the shape using left hand turns. somehow find any regions totally surrounded by this region and add their perimiter

    /*
     DIFFERENT IDEA. Use a 2x2 window scanning over each region. Different patterns in that window would produce a different number of corners and the number of corners and sides is the same.

     For example, for region that is just "X" scanning over it would yeild:

     ..  ..
     .X  X.

     .X  X.
     ..  ..

     Each of these would add one corner, yielding the poper result of 4.

     Care would need to be taken that the window would extend one step *outside* the map.

     For "XX", you'd get the windows:

     ..  ..  ..
     .X  XX  X.

     .X  XX  X.
     ..  ..  ..

     */

    var total = 0
    for region in regions {
        let bounds = region.bounds
        var sides = 0

        for y in (bounds.y - 1)..<(bounds.y + bounds.height + 2) { // Maybe only need + 1 here?
            for x in (bounds.x - 1)..<(bounds.x + bounds.width + 2) { // Maybe only need + 1 here?
                /*
                 Make a 2x2 sample

                   c d
                   a b

                 Taking care that we are comparing only spots from the indicated region, not the letter used to form it since two completely different regions with the same letter could appeach across each other diagonally, but it could be the same region too where there are inner holes like:

                 XXXX
                 XX.X
                 X.XX
                 XXXX

                 */

                let a = locationToRegion[Location2D(x: x, y: y)] === region
                let b = locationToRegion[Location2D(x: x + 1, y: y)] === region
                let c = locationToRegion[Location2D(x: x, y: y + 1)] === region
                let d = locationToRegion[Location2D(x: x + 1, y: y + 1)] === region

                switch (a, b, c, d) {
                    case (true, false, false, false),
                    (false, true, false, false),
                    (false, false, true, false),
                    (false, false, false, true):
                    // One single "outer" corner in the window
                    sides += 1
                case (false, true, true, true),
                    (true, false, true, true),
                    (true, true, false, true),
                    (true, true, true, false):
                    // Any three set is a single "inner" corner
                    sides += 1
                case (true, true, false, false),
                    (false, false, true, true):
                    // Horizontal line passing through. No corners
                    break
                case (false, true, false, true),
                    (true, false, true, false):
                    // Vertical line passing through. No corners.
                    break
                case (false, false, false, false):
                    // Empty space. No corners
                    break
                case (true, true, true, true):
                    // Full space, No corners
                    break
                case (false, true, true, false),
                    (true, false, false, true):
                    // Diagonal kissing touch. Two corners!
                    sides += 2
                default:
                    print("Need patter for:")
                    print("\(c ? "X" : ".") \(d ? "X" : ".")")
                    print("\(a ? "X" : ".") \(b ? "X" : ".")")
                    fatalError()
                }
            }
        }

        print("region \(region.type) has \(sides) sides")
        total += region.area * sides
    }

    print("\(total)")
}
