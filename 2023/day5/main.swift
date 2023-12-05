import Foundation

let lines = Input.lines()

struct MapEntry {
    let destinationStart: Int
    let sourceStart: Int
    let length: Int

    init(line: String) {
        let numbers = line.numbers()
        self.destinationStart = numbers[0]
        self.sourceStart = numbers[1]
        self.length = numbers[2]
    }

    func contains(_ value: Int) -> Bool {
        return value >= sourceStart && value < sourceStart + length
    }

    func map(_ value: Int) -> Int {
        return (value - sourceStart) + destinationStart
    }
}

class Map {
    var entries = [MapEntry]()

    func map(_ value: Int) -> Int {
        for entry in entries {
            if entry.contains(value) {
                return entry.map(value)
            }
        }
        return value
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
        currentMap!.entries.append(entry)
    }
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
    //assert(lowest == 650599855)
}

do {
    var lowest = seeds.max()! + 1

    var remaining = seeds
    while !remaining.isEmpty {
        let base = remaining[0]
        let length = remaining[1]
        remaining.removeSubrange(0..<2)

        for seed in base..<base+length {
            var result = seed
            for map in maps {
                result = map.map(result)
            }
            if result < lowest {
                lowest = result
            }
        }
    }

    print("\(lowest)")
}
