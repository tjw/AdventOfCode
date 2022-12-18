//
//  main.swift
//  day15
//
//  Created by Timothy Wood on 12/16/22.
//

import Foundation

struct Sensor {
    let location: Location
    let nearestBeacon: Location

    // Manhattan "radius" from the sensor location to the beacon
    var excludedRadius: Int {
        location.manhattanDistance(to: nearestBeacon)
    }
}

let regex = /Sensor at x=([-0-9]+), y=([-0-9]+): closest beacon is at x=([-0-9]+), y=([-0-9]+)/
let sensors: [Sensor] = Input.lines().map { line in
    let match = try! regex.wholeMatch(in: line)!
    return Sensor(location: Location(x: Int(match.1)!, y: Int(match.2)!),
                  nearestBeacon: Location(x: Int(match.3)!, y: Int(match.4)!))
}

let candidateY = 2000000

// For each sensor, find the range of the candidate Y line that intersects its exclusion diamond.
// If the sensor is on exactly this Y, its range will start radius units before the sensor and end that far after for a total length of (radius + 1 + radius), with one for the sensor itself. Each Y offset above or below the sensor, the effective radius goes down by one (so the width goes down by two) until at Y +/- radius where the range has width 1. Beyond that, the Y line doesn't intersect the exclusion radius of that sensor.
// Ranges might also be overlapping, so sort them by their lower bound for following processing

let ranges: [Range<Int>] = sensors.compactMap { sensor in
    print("sensor at \(sensor.location), nearest beacon: \(sensor.nearestBeacon), excluded radius \(sensor.excludedRadius)")
    let maxWidth = 2*sensor.excludedRadius + 1
    print("  maxWidth \(maxWidth)")

    let yOffset = abs(candidateY - sensor.location.y)
    print("  yOffset \(yOffset)")

    let width = maxWidth - 2*yOffset
    print("  width \(width)")

    guard width > 0 else {
        print("  no intersection")
        return nil
    }

    let effectiveRadius = (width - 1)/2
    print("  effectiveRadius \(effectiveRadius)")

    let result = (sensor.location.x - effectiveRadius)..<(sensor.location.x + effectiveRadius + 1)
    print("  result \(result)")
    return result
}.sorted(by: { a, b in
    a.lowerBound < b.lowerBound
})

print("ranges \(ranges)")

var total = 0
var currentRange = ranges.first!
print("# starting range \(currentRange)")

for range in ranges.dropFirst() {
    print("# next range \(range)")

    if (currentRange.upperBound >= range.upperBound) {
        // new range completely contained by the current range
        print("  current range of \(currentRange) entirely contains next range \(range)")
    } else if range.contains(currentRange.upperBound) {
        // candidate range overlaps the current range and so extends it
        let previousCurrentRange = currentRange
        currentRange = currentRange.lowerBound..<range.upperBound
        print("  previous current range of \(previousCurrentRange) overlaps next range \(range), new candidateEndX is \(currentRange)")
    } else {
        let currentRangeLength = currentRange.upperBound - currentRange.lowerBound - 1
        total += currentRangeLength
        currentRange = range
        print("  add \(currentRangeLength) to total, new current range of \(currentRange)")
    }
}

print("  adding final \(currentRange.upperBound - currentRange.lowerBound) to total")
total += currentRange.upperBound - currentRange.lowerBound - 1
print("total \(total)")
assert(total == 5809294)

/* This comes out one off somehow
var indexSet = IndexSet()
var offset = ranges.first!.lowerBound

for range in ranges {
    print("range \(range)")
    let offsetRange = (range.lowerBound - offset)..<(range.upperBound - offset)
    print("offsetRange \(offsetRange)")

    indexSet.insert(integersIn: offsetRange)
    print("  count now \(indexSet.count)")
}

print("count \(indexSet.count)")
 */
// 6969021 is too high
// 5139102 is too low
// 5139103 is not right
// 5809295 is not right

