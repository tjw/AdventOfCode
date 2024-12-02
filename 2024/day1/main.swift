import Foundation

let lines = Input.lines()

let pairs = lines.map { $0.numbers() }
let lefts = pairs.map { $0[0] } .sorted()
let rights = pairs.map { $0[1] } .sorted()

// part 1
do {
    let total = zip(lefts, rights).reduce(0, { partial, pair in
        let dist = abs(pair.0 - pair.1)
        return partial + dist
    })
    print("\(total)")
    assert(total == 1319616)
}

// part 2
do {
    var counts = [Int:Int]()
    rights.forEach { right in
        counts[right] = (counts[right] ?? 0) + 1
    }

    let total = lefts.reduce(0, {
        $0 + $1 * (counts[$1] ?? 0)
    })
    print("\(total)")
    assert(total == 27267728)
}
