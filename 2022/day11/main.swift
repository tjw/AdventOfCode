//
//  main.swift
//  day11
//
//  Created by Timothy Wood on 12/10/22.
//

import Foundation

/*
 In part 2, the item worry levels quickly overflow 64-bit Ints. All the 'tests' are vs primes, so the hint is to store worry levels as prime factorizations.

 Some of the operations are simple, for example, `$0 * 19` would find the 19 bucket and increment it. `$0 * $0` can double each bucket.

 Addition is a problem. For example, 5^2 + 1 = 26 = 13^2
 */

/*
 Rather, let's try remembering the modulo class of the current state for each of the possible tests.
 */

protocol ItemValueType {
    init(value: Int)

    static func *(left: Self, a: Int) -> Self
    static func *(left: Self, right: Self) -> Self
    static func +(left: Self, a: Int) -> Self
    static func /?(value: Self, divisor: Int) -> Bool
}

extension Int : ItemValueType {
    init(value: Int) {
        self = value
    }
}

// Rather than return the modulus and having to check if its zero, this is a 'evenly divides' resulting in a Bool
infix operator /?

extension Int {
    static func /?(value: Int, divisor: Int) -> Bool {
        return value % divisor == 0
    }
}

struct ItemModuloClasses : ItemValueType, Equatable {
    static let primes = [2, 3, 5, 7, 11, 13, 15, 17, 19, 23]

    var value: Int // Debugging; keep the original value and work it it too
    var moduloResidues: [Int]

    init(value: Int) {
        self.value = value
        self.moduloResidues = Self.primes.map { value % $0 }
    }
    private init(value: Int, moduloResidues: [Int]) {
        self.value = value
        self.moduloResidues = moduloResidues

        zip(moduloResidues, Self.primes).forEach { residue, prime in
            assert(value % prime == residue)
        }
    }

    static func *(left: ItemModuloClasses, a: Int) -> ItemModuloClasses {
        let value = left.value * a
        let moduloResidues = zip(left.moduloResidues, Self.primes).map { residue, prime in
            (residue * a) % prime
        }
        return Self(value: value, moduloResidues: moduloResidues)
    }
    static func *(left: ItemModuloClasses, right: ItemModuloClasses) -> ItemModuloClasses {
        // BAD: This only works here for p=2
        // According to Fermat's Little Theorem, a^p = a mod p
        assert(left == right)
        //return left

        let value = left.value * right.value

        let residues = (0..<Self.primes.count).map { idx in
            let left = left.moduloResidues[idx]
            let right = right.moduloResidues[idx]
            let prime = Self.primes[idx]
            return (left * right) % prime
        }
        return Self(value: left.value * right.value, moduloResidues: residues)
    }
    static func +(left: ItemModuloClasses, a: Int) -> ItemModuloClasses {
        let value = left.value + a
        let moduloResidues = zip(left.moduloResidues, Self.primes).map { residue, prime in
            (residue + a) % prime
        }
        return Self(value: value, moduloResidues: moduloResidues)
    }
    static func /?(value: ItemModuloClasses, divisor: Int) -> Bool {
        let primeIndex = Self.primes.firstIndex(of: divisor)!
        assert(value.moduloResidues[primeIndex] == value.value % divisor)
        return value.moduloResidues[primeIndex] == 0
    }
}

class Monkey<ItemValue: ItemValueType> {
    var items: [ItemValue]
    var operation: (ItemValue) -> ItemValue // old item worry level -> new item worry level
    var test: (ItemValue) -> Int // Item worry level to destination monkey

    var inspections = 0

    init(items: [Int], operation: @escaping (ItemValue) -> ItemValue, test: @escaping (ItemValue) -> Int) {
        self.items = items.map { ItemValue(value: $0) }
        self.operation = operation
        self.test = test
    }
}

// Hand translated the input to Swift instead of writing parsing code
func makeMonkeys<ItemValue: ItemValueType>() -> [Monkey<ItemValue>] {
    [
        Monkey(items: [57, 58],
               operation: { $0 * 19},
               test: { $0 /? 7 ? 2 : 3}),

        Monkey(items: [66, 52, 59, 79, 94, 73],
               operation: { $0 + 1},
               test: { $0 /? 19 ? 4 : 6}),

        Monkey(items: [80],
               operation: { $0 + 6},
               test: { $0 /? 5 ? 7 : 5}),

        Monkey(items: [82, 81, 68, 66, 71, 83, 75, 97],
               operation: { $0 + 5},
               test: { $0 /? 11 ? 5 : 2}),

        Monkey(items: [55, 52, 67, 70, 69, 94, 90],
               operation: { $0 * $0 },
               test: { $0 /? 17 ? 0 : 3}),

        Monkey(items: [69, 85, 89, 91],
               operation: { $0 + 7 },
               test: { $0 /? 13 ? 1 : 7}),

        Monkey(items: [75, 53, 73, 52, 75],
               operation: { $0 * 7 },
               test: { $0 /? 2 ? 0 : 4}),

        Monkey(items: [94, 60, 79],
               operation: { $0 + 2 },
               test: { $0 /? 3 ? 1 : 6}),
    ]
}

func makeTestMonkeys<ItemValue: ItemValueType>() -> [Monkey<ItemValue>] {
    [
        Monkey(items: [79, 98],
               operation: { $0 * 19 },
               test: { $0 /? 23 ? 2 : 3 }),

        Monkey(items: [54, 65, 75, 74],
               operation: { $0 + 6},
               test: { $0 /? 19 ? 2 : 0}),

        Monkey(items: [79, 60, 97],
               operation: { $0 * $0 },
               test: { $0 /? 13 ? 1 : 3}),

        Monkey(items: [74],
               operation: { $0 + 3},
               test: { $0 /? 17 ? 0 : 1 }),
    ]
}

//do {
//    let monkeys: [Monkey<Int>] = makeMonkeys()
//
//    (0..<20).forEach { round in
//        monkeys.forEach { monkey in
//            for var item in monkey.items {
//                monkey.inspections += 1
//
//                item = monkey.operation(item)
//                item /= 3
//                let target = monkeys[monkey.test(item)]
//                assert(target !== monkey) // Maintaining the item list gets more complicated if a monkey can throw to itself
//
//                target.items.append(item)
//            }
//
//            monkey.items = [] // All items thrown
//        }
//    }
//
//    let sorted = monkeys.sorted { $0.inspections > $1.inspections }
//
//    sorted.forEach { monkey in
//        print("inspected \(monkey.inspections) items")
//    }
//
//    let result = sorted[0].inspections * sorted[1].inspections
//    print("\(result)")
//    assert(result == 50830)
//}

do {
    let monkeys: [Monkey<ItemModuloClasses>] = makeTestMonkeys()

    (0..<20).forEach { round in
        print("## Round \(round) ##")

        monkeys.indices.forEach { monkeyIndex in
            let monkey = monkeys[monkeyIndex]
            print("# Monkey \(monkeyIndex)")

            for old in monkey.items {
                monkey.inspections += 1

                let new = monkey.operation(old)
                print("operation \(old) -> \(new)")

                let targetIndex = monkey.test(new)
                print("target \(targetIndex)")

                let target = monkeys[targetIndex]
                assert(target !== monkey) // Maintaining the item list gets more complicated if a monkey can throw to itself

                target.items.append(new)
            }

            monkey.items = [] // All items thrown
        }
    }

    monkeys.forEach { monkey in
        print("inspected \(monkey.inspections) items")
    }

//    let sorted = monkeys.sorted { $0.inspections > $1.inspections }
//
//    sorted.forEach { monkey in
//        print("inspected \(monkey.inspections) items")
//    }
//
//    let result = sorted[0].inspections * sorted[1].inspections
//    print("\(result)")
    // 13056475300 too low
}
