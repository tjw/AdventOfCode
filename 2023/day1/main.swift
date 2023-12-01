import Foundation

let lines = Input.lines(includeEmpty: true)

do {
    var sum = 0
    for line in lines {
        let digits = line.filter(\.isNumber)
        guard !digits.isEmpty else { continue }

        let number = Int(String(digits.first!))! * 10 + Int(String(digits.last!))!
        sum += number
    }
    print("\(sum)")
    assert(sum == 54667)
}

// Part 2 hint from reddit: The right calibration values for string "eighthree" is 83 and for "sevenine" is 79. The examples do not cover such cases.
do {
    let numbers = [
        "one",
        "1",
        "two",
        "2",
        "three",
        "3",
        "four",
        "4",
        "five",
        "5",
        "six",
        "6",
        "seven",
        "7",
        "eight",
        "8",
        "nine",
        "9"
    ]

    var sum = 0

    for line in lines {
        guard !line.isEmpty else { continue }

        var first: Int?
        do {
            var remaining = line
            var found = false

            while !found && !remaining.isEmpty {
                for pair in numbers.enumerated() {
                    if remaining.hasPrefix(pair.element) {
                        first = (pair.offset / 2) + 1
                        found = true
                    }
                }
                if !found {
                    remaining = String(remaining.dropFirst())
                }
            }
        }

        var last: Int?
        do {
            var remaining = line
            var found = false

            while !found && !remaining.isEmpty {
                for pair in numbers.enumerated() {
                    if remaining.hasSuffix(pair.element) {
                        last = (pair.offset / 2) + 1
                        found = true
                    }
                }
                if !found {
                    remaining = String(remaining.dropLast())
                }
            }
        }

        let number = first! * 10 + last!
        sum += number

    }

    print("\(sum)")
    assert(sum == 54203)
}
