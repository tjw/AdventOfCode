import Foundation

let lines = Input.lines(includeEmpty: true)

class Elf {
    var items: [Int] = []

    var total: Int {
        items.reduce(0, +)
    }
}

var elves = [Elf]()

// Something in Swift Algorithms?

extension Array {
    func indexOfMaximum<Value>(transform: (Element) -> Value) -> Index? where Value : Comparable {
        var currentOffset: Int?
        var currentValue: Value?

        enumerated().forEach { offset, element in
            let value = transform(element)
            if currentOffset == nil || value > currentValue! {
                currentOffset = offset
                currentValue = value
            }
        }

        return currentOffset
    }
}

extension Array where Element : Comparable {
    var indexOfMaximum: Int? {
        return indexOfMaximum(transform: { $0 })
    }
}

do {
    var elf = Elf()
    elves.append(elf) // Assumes there won't be a blank line at the end

    for line in lines {
        if line.isEmpty {
            elf = Elf()
            elves.append(elf)
        } else {
            let calories = Int(line)!
            elf.items.append(calories)
        }
    }

    let maxElf = elves[elves.indexOfMaximum(transform: { $0.total })!]
    print("\(maxElf.total)")
    assert(maxElf.total == 69836)
}

do {
    let sortedElves = elves.sorted { $0.total > $1.total }

    let total = sortedElves[0..<3].reduce(0, { $0 + $1.total })
    print("\(total)")
    assert(total == 207968)
}
