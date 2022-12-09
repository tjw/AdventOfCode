

enum Shape: Int {
    case rock = 1
    case paper = 2
    case scissors = 3

    init(rawValue: String) {
        switch rawValue {
        case "A", "X":
            self = .rock
        case "B", "Y":
            self = .paper
        case "C", "Z":
            self = .scissors
        default:
            fatalError()
        }
    }

    func response(for result: Result) -> Shape {
        switch (self, result) {
        case (_, .draw): return self

        case (.rock, .win): return .paper
        case (.rock, .lose): return .scissors

        case (.paper, .win): return .scissors
        case (.paper, .lose): return .rock

        case (.scissors, .win): return .rock
        case (.scissors, .lose): return .paper
        }
    }
}

enum Result: Int {
    case lose = 0
    case draw = 3
    case win = 6

    init(rawValue: String) {
        switch rawValue {
        case "X":
            self = .lose
        case "Y":
            self = .draw
        case "Z":
            self = .win
        default:
            fatalError()
        }
    }
}

struct Move {
    let elf: Shape
    let player: Shape

    var result: Result {
        switch (elf, player) {
        case (.rock, .rock): return .draw
        case (.paper, .paper): return .draw
        case (.scissors, .scissors): return .draw

        case (.rock, .paper): return .win
        case (.rock, .scissors): return .lose

        case (.paper, .rock): return .lose
        case (.paper, .scissors): return .win

        case (.scissors, .rock): return .win
        case (.scissors, .paper): return .lose
        }
    }
}

func evaluate(moves: [Move]) -> Int {
    var score = 0

    moves.forEach { move in
        let result = move.result
        score += result.rawValue + move.player.rawValue
    }

    return score
}

let lines = Input.lines()

do {
    let moves: [Move] = lines.compactMap { line in
        guard !line.isEmpty else { return nil }
        let components = line.split(separator: " ")
        return Move(elf: Shape(rawValue: String(components[0])), player: Shape(rawValue: String(components[1])))
    }

    let score = evaluate(moves: moves)

    print("\(score)")
    assert(score == 11666)
}

do {
    let moves: [Move] = lines.compactMap { line in
        guard !line.isEmpty else { return nil }
        let components = line.split(separator: " ")
        let elf = Shape(rawValue: String(components[0]))
        let result = Result(rawValue:  String(components[1]))
        return Move(elf: elf, player: elf.response(for: result))
    }

    let score = evaluate(moves: moves)

    print("\(score)")
    assert(score == 12767)
}
