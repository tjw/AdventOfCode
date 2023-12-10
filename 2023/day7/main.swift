//
//  main.swift
//  day7
//
//  Created by Timothy Wood on 12/6/23.
//

import Foundation

let lines = Input.lines()

enum HandType : Comparable {
    case fiveOfAKind
    case fourOfAKind
    case fullHouse
    case threeOfAKind
    case twoPair
    case onePair
    case highCard // Feels like this should be holding the high card value, but not seeing it in the puzzle
}

// Part 1
    enum Card1 : Character, RawRepresentable, CaseIterable, Comparable {
        case A = "A"
        case K = "K"
        case Q = "Q"
        case J = "J"
        case T = "T"
        case _9 = "9"
        case _8 = "8"
        case _7 = "7"
        case _6 = "6"
        case _5 = "5"
        case _4 = "4"
        case _3 = "3"
        case _2 = "2"

        var value: Int {
            switch self {

            case .A:
                return 14
            case .K:
                return 13
            case .Q:
                return 12
            case .J:
                return 11
            case .T:
                return 10
            case ._9:
                return 9
            case ._8:
                return 8
            case ._7:
                return 7
            case ._6:
                return 6
            case ._5:
                return 5
            case ._4:
                return 4
            case ._3:
                return 3
            case ._2:
                return 2
            }
        }

        // MARK:- Comparable

        static func < (lhs: Card1, rhs: Card1) -> Bool {
            return lhs.value < rhs.value
        }

    }

    struct Hand1 : Comparable, CustomStringConvertible {

        let cards: [Card1]
        let bid: Int

        var type: HandType {
            var counts = [Card1:Int]()

            for card in cards {
                counts[card] = (counts[card] ?? 0) + 1
            }

            var countCounts = [Int:Int]()

            for pair in counts {
                countCounts[pair.value] = (countCounts[pair.value] ?? 0) + 1
            }

            if let _ = countCounts[5] {
                return .fiveOfAKind
            }
            if let _ = countCounts[4] {
                return .fourOfAKind
            }
            if let _ = countCounts[3], let _ = countCounts[2] {
                return .fullHouse
            }
            if let _ = countCounts[3] {
                return .threeOfAKind
            }
            if countCounts[2] == 2 {
                return .twoPair
            }
            if countCounts[2] == 1 {
                return .onePair
            }
            return .highCard
        }

        // MARK:- Comparable

        static func < (lhs: Hand1, rhs: Hand1) -> Bool {
            let leftType = lhs.type
            let rightType = rhs.type

            if leftType != rightType {
                return leftType < rightType
            }

            for pair in zip(lhs.cards, rhs.cards) {
                guard pair.0 != pair.1 else { continue }
                return pair.0 > pair.1
            }

            fatalError("Not reached")
        }

        // MARK:- CustomStringConvertible

        var description: String {
            "\(String(cards.map(\.rawValue))) @ \(bid)"
        }
    }

    do {
        let hands = lines.map { line in
            let components = line.split(separator: " ")
            let cards = components[0].map { Card1(rawValue: $0)! }
            let bid = Int(components[1])!
            return Hand1(cards: cards, bid: bid)
        }.sorted().reversed()

        for hand in hands {
            print("hand \(hand), type \(hand.type)")
        }

        var result = 0
        zip(hands, 1...hands.count).forEach { hand, rank in
            print("hand \(hand), rank \(rank)")
            result += hand.bid * rank
        }
        print("\(result)")
    }

// Part 2, not trying to make the same types work for the Joker case

    enum Card2 : Character, RawRepresentable, CaseIterable, Comparable {
        case A = "A"
        case K = "K"
        case Q = "Q"
        case T = "T"
        case _9 = "9"
        case _8 = "8"
        case _7 = "7"
        case _6 = "6"
        case _5 = "5"
        case _4 = "4"
        case _3 = "3"
        case _2 = "2"
        case J  = "J"

        var value: Int {
            switch self {

            case .A:
                return 14
            case .K:
                return 13
            case .Q:
                return 12
            case .T:
                return 10
            case ._9:
                return 9
            case ._8:
                return 8
            case ._7:
                return 7
            case ._6:
                return 6
            case ._5:
                return 5
            case ._4:
                return 4
            case ._3:
                return 3
            case ._2:
                return 2
            case .J:
                return 1
            }
        }

        // MARK:- Comparable

        static func < (lhs: Card2, rhs: Card2) -> Bool {
            return lhs.value < rhs.value
        }

    }

    struct Hand2 : Comparable, CustomStringConvertible {

        let cards: [Card2]
        let bid: Int

        var type: HandType {
            var counts = [Card2:Int]()

            for card in cards {
                counts[card] = (counts[card] ?? 0) + 1
            }

            let jokerCount = counts[.J] ?? 0
            counts.removeValue(forKey: .J)

            var countCounts = [Int:Int]()

            for pair in counts {
                countCounts[pair.value] = (countCounts[pair.value] ?? 0) + 1
            }

            // If there is only one kind of card, plus some number of jokers, then we can make five of a kind
            if counts.count == 1 || (counts.count == 0 && jokerCount == 5) {
                assert((counts.first?.value ?? 0) + jokerCount == 5)
                return .fiveOfAKind
            }

            // If at least one count + number of jokers is 4, we can make four of a kind
            for pair in counts {
                if pair.1 + jokerCount == 4 {
                    return .fourOfAKind
                }
            }

            // If there are only two kinds of cards, and the previous ones haven't matched, then it must be possible to make a full house
            if counts.count == 2 {
                return .fullHouse
            }

            // If at least one count + number of jokers is 3, we can make three of a kind
            for pair in counts {
                if pair.1 + jokerCount == 3 {
                    return .threeOfAKind
                }
            }

            assert(jokerCount <= 1, "If we have more than one joker, we could have make three of a kind")

            if countCounts[2] == 2 || (countCounts[2] == 1 && jokerCount == 1) {
                return .twoPair
            }

            if countCounts[2] == 1 || jokerCount == 1 {
                return .onePair
            }

            assert(jokerCount == 0, "If we had a joker, we could have made a pair")
            return .highCard
        }

        // MARK:- Comparable

        static func < (lhs: Hand2, rhs: Hand2) -> Bool {
            let leftType = lhs.type
            let rightType = rhs.type

            if leftType != rightType {
                return leftType < rightType
            }

            for pair in zip(lhs.cards, rhs.cards) {
                guard pair.0 != pair.1 else { continue }
                return pair.0 > pair.1
            }

            fatalError("Not reached")
        }

        // MARK:- CustomStringConvertible

        var description: String {
            "\(String(cards.map(\.rawValue))) @ \(bid)"
        }
    }

    do {
        let hands = lines.map { line in
            let components = line.split(separator: " ")
            let cards = components[0].map { Card2(rawValue: $0)! }
            let bid = Int(components[1])!
            return Hand2(cards: cards, bid: bid)
        }.sorted().reversed()

        for hand in hands {
            print("hand \(hand), type \(hand.type)")
        }

        var result = 0
        zip(hands, 1...hands.count).forEach { hand, rank in
            print("hand \(hand), rank \(rank)")
            result += hand.bid * rank
        }
        print("\(result)")
    }
