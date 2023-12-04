import Foundation

let lines = Input.lines()

// Card #: wins | have

class Card {
    let id: Int

    let winners: Set<Int>
    let picks: Set<Int>

    init(line: String) {
        let components = line.split(separator: /[:|]/)

        self.id = String(components[0]).trailingNumber
        self.winners = Set(String(components[1]).numbers())
        self.picks = Set(String(components[2]).numbers())
    }

    var matches: Set<Int> {
        winners.intersection(picks)
    }
}

let cards = lines.map { Card(line: $0) }

do {
    var result = 0

    for card in cards {
        let matches = card.matches
        result += 1 << (matches.count - 1)
    }

    print("\(result)")
    assert(result == 22488)
}

do {
    var pile = cards
    var pileIndex = 0

    while pileIndex < pile.count {
        let card = pile[pileIndex]
        pileIndex += 1

        let matchCount = card.matches.count
        guard matchCount > 0 else { continue }

        // Duplicate the next matchCount cards
        for matchIndex in 0..<matchCount {
            let card = pile[card.id - 1 + matchIndex + 1] // card.id is one based, but we want the cards after, so the -1 and +1 cancel out, but being specific
            pile.append(card)
        }
    }

    let result = pile.count
    print("\(result)")
    assert(result == 7013204)
}
