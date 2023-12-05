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

    // ASSUME: None of the source ranges overlap
    // Mapping a source range can result in one mapped destination, and one or more unmapped ranges that didn't intersect this entry, but might intersect others.

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

//    func map(_ range: Range<Int>) -> [Range<Int>] {
//        entries.flatMap { $0.map(range) }
//    }
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

/*
do {
    var lowest = seeds.max()! + 1

    var remaining = seeds
    while !remaining.isEmpty {
        let base = remaining[0]
        let length = remaining[1]
        remaining.removeSubrange(0..<2)

        let seedRange = base..<base+length

        // Map this one range through each of the maps, at each step possibly producing multiple ranges.
        var sourceRanges = [seedRange]
        var destinationRanges: [Range<Int>] = []

        // TODO: An invariant should be that the total length of the source range and dest ranges should be equal

        for map in maps {
            for source in sourceRanges {
                let dests = map.map(source)
                destinationRanges.append(contentsOf: dests)
            }

            sourceRanges = destinationRanges
            destinationRanges = []
        }
    }

    print("\(lowest)")
}
*/
