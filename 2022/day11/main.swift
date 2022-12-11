//
//  main.swift
//  day11
//
//  Created by Timothy Wood on 12/10/22.
//

import Foundation

class Monkey {
    var items: [Int]
    var operation: (Int) -> Int // old item worry level -> new item worry level
    var test: (Int) -> Int // Item worry level to destination monkey

    var inspections = 0

    init(items: [Int], operation: @escaping (Int) -> Int, test: @escaping (Int) -> Int) {
        self.items = items
        self.operation = operation
        self.test = test
    }
}

// Hand translated the input to Swift instead of writing parsing code
func makeMonkeys() -> [Monkey] {
    [
        Monkey(items: [57, 58],
               operation: { $0 * 19},
               test: { $0 % 7 == 0 ? 2 : 3}),

        Monkey(items: [66, 52, 59, 79, 94, 73],
               operation: { $0 + 1},
               test: { $0 % 19 == 0 ? 4 : 6}),

        Monkey(items: [80],
               operation: { $0 + 6},
               test: { $0 % 5 == 0 ? 7 : 5}),

        Monkey(items: [82, 81, 68, 66, 71, 83, 75, 97],
               operation: { $0 + 5},
               test: { $0 % 11 == 0 ? 5 : 2}),

        Monkey(items: [55, 52, 67, 70, 69, 94, 90],
               operation: { $0 * $0 },
               test: { $0 % 17 == 0 ? 0 : 3}),

        Monkey(items: [69, 85, 89, 91],
               operation: { $0 + 7 },
               test: { $0 % 13 == 0 ? 1 : 7}),

        Monkey(items: [75, 53, 73, 52, 75],
               operation: { $0 * 7 },
               test: { $0 % 2 == 0 ? 0 : 4}),

        Monkey(items: [94, 60, 79],
               operation: { $0 + 2 },
               test: { $0 % 3 == 0 ? 1 : 6}),
    ]
}

do {
    let monkeys = makeMonkeys()

    (0..<20).forEach { round in
        monkeys.forEach { monkey in
            for var item in monkey.items {
                monkey.inspections += 1

                item = monkey.operation(item)
                item /= 3
                let target = monkeys[monkey.test(item)]
                assert(target !== monkey) // Maintaining the item list gets more complicated if a monkey can throw to itself

                target.items.append(item)
            }

            monkey.items = [] // All items thrown
        }
    }

    let sorted = monkeys.sorted { $0.inspections > $1.inspections }

    sorted.forEach { monkey in
        print("inspected \(monkey.inspections) items")
    }

    let result = sorted[0].inspections * sorted[1].inspections
    print("\(result)")
    assert(result == 50830)
}

do {
    let monkeys = makeMonkeys()

    (0..<10000).forEach { round in
        monkeys.forEach { monkey in
            for var item in monkey.items {
                monkey.inspections += 1

                item = monkey.operation(item)
                let target = monkeys[monkey.test(item)]
                assert(target !== monkey) // Maintaining the item list gets more complicated if a monkey can throw to itself

                target.items.append(item)
            }

            monkey.items = [] // All items thrown
        }
    }

    let sorted = monkeys.sorted { $0.inspections > $1.inspections }

    sorted.forEach { monkey in
        print("inspected \(monkey.inspections) items")
    }

    let result = sorted[0].inspections * sorted[1].inspections
    print("\(result)")
}
