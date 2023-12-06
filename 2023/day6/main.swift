import Foundation

let lines = Input.lines()

struct Race {
    let duration: Int
    let record: Int

    var numberOfWins: Int {
//        print("race \(self)")
        var result = 0

        for hold in 0...duration {
            let speed = hold

            let distance = speed * (duration - hold)
//            print("  duration: \(duration), speed \(speed), distance \(distance)")
            if distance > record {
                result += 1
            }
        }

//        print("  numberOfWins \(result)")
        return result
    }
}

do {
    let durations = String(lines[0].split(separator: ":")[1]).numbers()
    let records = String(lines[1].split(separator: ":")[1]).numbers()
    let races = zip(durations, records).map { duration, record in
        Race(duration: duration, record: record)
    }

    var result: Int = 1

    races.forEach { race in
        result *= race.numberOfWins
    }

    print("\(result)")
    assert(result == 503424)
}

do {
    let duration = Int(String(lines[0].split(separator: ":")[1]).filter(\.isNumber))!
    let record = Int(String(lines[1].split(separator: ":")[1]).filter(\.isNumber))!
    let race = Race(duration: duration, record: record)

    let result = race.numberOfWins

    print("\(result)")
    assert(result == 32607562)
}
