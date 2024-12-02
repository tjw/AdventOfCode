import Foundation

let lines = Input.lines()
let reports = lines.numbers()

func isSafe(_ report: [Int]) -> Bool {
    if report[0] == report[1] {
        return false
    }
    let increasing = report[1] > report[0]

    var previous = report[0]
    for next in report.dropFirst() {
        if increasing != (next > previous) {
            return false
        }
        let diff = abs(next - previous)
        if diff < 1 || diff > 3 {
            return false
        }
        previous = next
    }

    return true
}

do {
    let count = reports.count(where: isSafe(_:))
    print("\(count)")
    assert(count == 585)
}

do {
    func isKindSafe(_ report: [Int]) -> Bool {
        if isSafe(report) {
            return true
        }

        for levelIndex in 0..<report.count {
            var modified = report
            modified.remove(at: levelIndex)
            if isSafe(modified) {
                return true
            }
        }
        return false
    }

    let count = reports.count(where: isKindSafe(_:))
    print("\(count)")
    assert(count == 626)
}
