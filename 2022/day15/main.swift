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

func excludedRanges(candidateY: Int, in allowedXRange: ClosedRange<Int>?) -> [ClosedRange<Int>] {
    // For each sensor, find the range of the candidate Y line that intersects its exclusion diamond.
    // If the sensor is on exactly this Y, its range will start radius units before the sensor and end that far after for a total length of (radius + 1 + radius), with one for the sensor itself. Each Y offset above or below the sensor, the effective radius goes down by one (so the width goes down by two) until at Y +/- radius where the range has width 1. Beyond that, the Y line doesn't intersect the exclusion radius of that sensor.
    // Ranges might also be overlapping, so sort them by their lower bound for following processing

    let ranges: [ClosedRange<Int>] = sensors.compactMap { (sensor: Sensor) -> ClosedRange<Int>? in
        //print("sensor at \(sensor.location), nearest beacon: \(sensor.nearestBeacon), excluded radius \(sensor.excludedRadius)")
        let maxWidth = 2*sensor.excludedRadius + 1
        //print("  maxWidth \(maxWidth)")

        let yOffset = abs(candidateY - sensor.location.y)
        //print("  yOffset \(yOffset)")

        let width = maxWidth - 2*yOffset
        //print("  width \(width)")

        guard width > 0 else {
            //print("  no intersection")
            return nil
        }

        let effectiveRadius = (width - 1)/2
        //print("  effectiveRadius \(effectiveRadius)")

        let result = (sensor.location.x - effectiveRadius)...(sensor.location.x + effectiveRadius)
        //print("  result \(result)")

        if let allowedXRange {
            let minX: Int = max(result.lowerBound, allowedXRange.lowerBound)
            let maxX: Int = min(result.upperBound, allowedXRange.upperBound)
            let clamped: ClosedRange<Int> = minX...maxX
            //print("  clamped \(clamped)")
            return clamped
        }

        return result
    }.sorted(by: { a, b in
        a.lowerBound < b.lowerBound
    })

    //print("ranges \(ranges)")
    return ranges
}

func combineExcludedRanges(ranges: [ClosedRange<Int>]) -> [ClosedRange<Int>] {
    var result = [ClosedRange<Int>]()
    var currentRange = ranges.first!

    for range in ranges.dropFirst() {
        if (currentRange.upperBound >= range.upperBound) {
            // new range completely contained by the current range
        } else if range.contains(currentRange.upperBound) {
            currentRange = currentRange.lowerBound...range.upperBound
        } else {
            result.append(currentRange)
            currentRange = range
        }
    }

    result.append(currentRange)
    return result
}

func countExcludedRanges(ranges: [ClosedRange<Int>]) -> Int {
    var total = 0

    for range in combineExcludedRanges(ranges: ranges) {
        total += range.upperBound - range.lowerBound
    }

    //print("total \(total)")
    return total
}

do {
    let ranges = excludedRanges(candidateY: 2_000_000, in: nil)
    let result = countExcludedRanges(ranges: ranges)
    print("result \(result)")
    assert(result == 5809294)
}

do {
    let allowedRange = 0...4_000_000

    for y in 3308000...4_000_000 {
        let ranges = excludedRanges(candidateY: y, in: allowedRange)
        let combinedRanges = combineExcludedRanges(ranges: ranges)
        let count = countExcludedRanges(ranges: combinedRanges)
        if (y % 1_000 == 0) {
            print("y \(y)")
        }
        if count < 4_000_000 {
            print("y \(y), count \(count), combinedRanges \(combinedRanges)")

            assert(combinedRanges.count == 2)

            let x = combinedRanges.first!.upperBound + 1
            assert(x == 2673432)

            let result = x * 4000000 + y
            print("\(result)")
            assert(result == 10693731308112)

            break
        }
    }
}
