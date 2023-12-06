import Foundation

let lines = Input.lines()

struct MapEntry : Comparable {
    let source: Range<Int>
    let offset: Int

    init(line: String) {
        let numbers = line.numbers()

        let destinationStart = numbers[0]
        let sourceStart = numbers[1]
        let length = numbers[2]

        self.source = sourceStart ..< sourceStart + length
        self.offset = destinationStart - sourceStart
    }

    func contains(_ value: Int) -> Bool {
        source.contains(value)
    }

    func map(_ value: Int) -> Int {
        value + offset
    }

    func overlaps(_ other: MapEntry) -> Bool {
        source.overlaps(other.source)
    }


    struct RangeMapResult {
        let mapped: Range<Int>?
        let unmapped: [Range<Int>]
    }

//    func map(_ range: Range<Int>) -> [Range<Int>] {
//        var result = [Range<Int>]()
//
//        if range.startIndex < sourceStart {
//            let leadingLength = sourceStart - range.startIndex
//            result.append(destinationStart + leadingLength ..< destinationStart + leadingLength)
//        }
//        abort()
//    }

    // MARK:- Comparable

    static func < (lhs: MapEntry, rhs: MapEntry) -> Bool {
        lhs.source.lowerBound < rhs.source.lowerBound
    }

}

class Map {
    private(set) var entries = [MapEntry]()

    func map(_ value: Int) -> Int {
        for entry in entries {
            if entry.contains(value) {
                return entry.map(value)
            }
        }
        return value
    }

    func insert(entry: MapEntry) {
        entries.insertInSortedOrder(entry)
    }

    var hasOverlaps: Bool {
        var a: MapEntry = entries.first!
        for b in entries.dropFirst() {
            if a.overlaps(b) {
                return true
            }
            a = b
        }
        return false
    }

    func map(_ ranges: [Range<Int>]) -> [Range<Int>] {
        // Mapping a source range can result in one mapped destination, and one or more unmapped ranges that didn't intersect this entry, but might intersect others. Keep a list of ranges yet to be mapped
        var unmapped: [Range<Int>].SubSequence = ranges[...]
        var mapped = [Range<Int>]()

        print("original ranges \(ranges)")

        while !unmapped.isEmpty {
            var range = unmapped.first!
            print("unmapped range \(range)")

            unmapped = unmapped.dropFirst()

            // TODO: Could use sorted order of map entries to find where to start with binary search
            // Check each map entry vs the range we have
            for entry in entries {
                guard range.overlaps(entry.source) else { continue }

                print("  entry \(entry.source) \(entry.offset)")

                // Check if some of this range is before the map entry. If so, put that portion in the unmapped list and trim it off our working range.
                if range.lowerBound < entry.source.lowerBound {
                    let prefix = range.lowerBound ..< entry.source.lowerBound
                    let trimmed = entry.source.lowerBound ..< range.upperBound
                    print("    prefix \(prefix), trimmed \(trimmed)")
                    assert(prefix.count + trimmed.count == range.count)
                    assert(!trimmed.isEmpty) // Otherwise the two ranges shouldn't have overlapped

                    unmapped.append(prefix)
                    range = trimmed
                }

                // Likewise, check if some of this range is after the map entry.
                if range.upperBound > entry.source.upperBound {
                    let suffix = entry.source.upperBound ..< range.upperBound
                    let trimmed = range.lowerBound ..< entry.source.upperBound
                    print("    trimmed \(trimmed), suffix \(suffix)")
                    assert(trimmed.count + suffix.count == range.count)
                    assert(!trimmed.isEmpty) // Otherwise the two ranges shouldn't have overlapped

                    unmapped.append(suffix)
                    range = trimmed
                }

                // If this range is entirely contained in the entry's source range, it is entirely used up and no further processing of entries is needed
                if entry.source.contains(range) {
                    print("    contained \(range)")
                    mapped.append(range.offset(by: entry.offset))
                    range = range.lowerBound ..< range.lowerBound // Mark as empty to signal it's all been handled
                    break
                }

                fatalError("finish")
            }

            // If there is any remaining range, it wasn't mapped by any entry and so maps to its current value
            if !range.isEmpty {
                print("    no entry \(range)")
                mapped.append(range)
            }
        }

        assert(ranges.reduce(0, { $0 + $1.count }) == mapped.reduce(0, { $0 + $1.count }))
        return mapped
    }
}

var seeds = [Int]()

var seedToSoil = Map()
var soilToFertilizer = Map()
var fertilizerToWater = Map()
var waterToLight = Map()
var lightToTemperature = Map()
var temperatureToHumidity = Map()
var humidityToLocation = Map()

let maps: [Map] = [
    seedToSoil,
    soilToFertilizer,
    fertilizerToWater,
    waterToLight,
    lightToTemperature,
    temperatureToHumidity,
    humidityToLocation
]

var currentMap: Map? = nil

for line in lines {
    if line.hasPrefix("seeds:") {
        seeds = String(line.split(separator: ":").last!).numbers()
    } else if line.hasPrefix("seed-to-soil") {
        currentMap = seedToSoil
    } else if line.hasPrefix("soil-to-fertilizer") {
        currentMap = soilToFertilizer
    } else if line.hasPrefix("seed-to-soil") {
        currentMap = seedToSoil
    } else if line.hasPrefix("fertilizer-to-water") {
        currentMap = fertilizerToWater
    } else if line.hasPrefix("seed-to-soil") {
    currentMap = seedToSoil
    } else if line.hasPrefix("water-to-light") {
        currentMap = waterToLight
    } else if line.hasPrefix("light-to-temperature") {
        currentMap = lightToTemperature
    } else if line.hasPrefix("temperature-to-humidity") {
        currentMap = temperatureToHumidity
    } else if line.hasPrefix("humidity-to-location") {
        currentMap = humidityToLocation
    } else if !line.isEmpty {
        let entry = MapEntry(line: line)
        currentMap!.insert(entry: entry)
    }
}

maps.forEach {
    assert($0.hasOverlaps == false)
}

do {
    var lowest = seeds.max()! + 1

    for seed in seeds {
        var result = seed
        for map in maps {
            result = map.map(result)
        }
        if result < lowest {
            lowest = result
        }
    }

    print("\(lowest)")
    assert(lowest == 650599855)
}

do {
    var lowest = seeds.max()! + 1

    // Start with the seed list as ranges
    var sourceRanges = seeds.ranges

    for map in maps {
        let destinationRanges = map.map(sourceRanges)

        // The total length of the source range and dest ranges should be equal
        assert(destinationRanges.reduce(0, { $0 + $1.count }) == sourceRanges.reduce(0, { $0 + $1.count }))
        sourceRanges = destinationRanges
    }

    lowest = min(lowest, (sourceRanges.map { $0.lowerBound }).min()!)

    print("\(lowest)")
    assert(lowest == 1240035)
}
