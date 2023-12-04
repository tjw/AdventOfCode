import Foundation

let lines = Input.lines()

class Entry {
    let ch: Character
    var touched: Bool = false
    var touchingNumbers = Set<Location2D>()

    init(ch: Character) {
        self.ch = ch
    }
}

let schematic = GridMap(elements: lines.map { line in
    line.map { ch in
        Entry(ch: ch)
    }
})

let dirs: [Location2D] = [
    .left,
    .right,
    .up,
    .down,
    .left + .up,
    .left + .down,
    .right + .up,
    .right + .down
]

extension Character {
    // isSymbol doesn't include '*' or '#'
    var isMarker: Bool {
        guard self != "." else { return false }
        guard !self.isNumber else { return false }
        assert(self == "*" || self == "+" || self == "#" || self == "$" || self == "&" || self == "/" || self == "@" || self == "=" || self == "%" || self == "-")
        return true
    }
}

schematic.forEach { center, entry in
    // Look for symbols at the current spot
    guard entry.ch.isMarker else { return }

    // Now, step in each direction and look for contiguous runs of numbers
    dirs.forEach { dir in
        let candidate = center + dir

        var step = candidate
        while let entry = schematic[step] {
            guard entry.ch.isNumber else {
                break
            }

            entry.touched = true
            step += .left
        }

        // If there were some numbers, tie their beginning to this symbol
        if step != candidate {
            schematic[center]!.touchingNumbers.insert(step - .left)
        }

        step = candidate
        while let entry = schematic[step] {
            guard entry.ch.isNumber else { break }

            entry.touched = true
            step += .right
        }
    }
}

//schematic.forEach { location, entry in
//    print("\(entry.ch)\(entry.touched ? "<" : " ")", terminator: location.x == schematic.width - 1 ? "\n" : "")
//}

do {
    var result = 0

    schematic.forEachRow { y, row in
        // Knock out untouched characters
        var string = String(row.map {
            $0.touched ? $0.ch : "."
        })

        while !string.isEmpty {
            if string.first!.isNumber {
                let end = string.firstIndex(where: { !$0.isNumber }) ?? string.endIndex
                let number = string[string.startIndex..<end]
                result += Int(number)!

                string = String(string[end...])
            } else {
                string = String(string.dropFirst())
            }
        }
    }

    print("\(result)")
    assert(result == 520135)
}

do {
    var result = 0

    schematic.forEach { location, entry in
        // Look for "gears" with two numbers
        guard entry.ch == "*" else { return }
        guard entry.touchingNumbers.count == 2 else {
            return
        }

        let numberLocations = Array(entry.touchingNumbers)

        let numbers = numberLocations.map { location in
            // Get the part of the row starting at this location
            let row = schematic.row(y: location.y).dropFirst(location.x)

            // Trim off the number prefix
            assert(row.first!.ch.isNumber)

            let string = row.map(\.ch)

            let number = Int(String(string.prefix(while: \.isNumber)))!
            return number
        }

        result += numbers[0] * numbers[1]
    }

    print("\(result)")
    assert(result == 72514855)
}
