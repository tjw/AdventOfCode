//
//  main.swift
//  day5
//
//  Created by Timothy Wood on 12/3/24.
//

import Foundation

let lines = Input.lines()

//do {
//    func hasRepeatedLetter(_ string: String) -> Bool {
//        var idx = string.startIndex
//        while idx != string.endIndex {
//            let next = string.index(after: idx)
//            if next == string.endIndex {
//                break
//            }
//            if string[idx] == string[next] {
//                return true
//            }
//            idx = next
//        }
//        return false
//    }
//
//    assert(hasRepeatedLetter("aa"))
//    assert(hasRepeatedLetter("1234567aa"))
//    assert(hasRepeatedLetter("1234567aa"))
//    assert(!hasRepeatedLetter("1234567ab"))
//    assert(!hasRepeatedLetter(""))
//
//    func isNice(_ string: String) -> Bool {
//        let vowelCount = string.count { ch in
//            // Should really use a CharacterSet but the API is weird with string enumeration
//            return ch == "a" || ch == "e" || ch == "i" || ch == "o" || ch == "u"
//        }
//        if vowelCount < 3 {
//            return false
//        }
//
//        if !hasRepeatedLetter(string) {
//            return false
//        }
//
//        if string.contains("ab") || string.contains("cd") || string.contains("pq") || string.contains("xy") {
//            return false
//        }
//
//        return true
//    }
//
//    let count = lines.count(where: isNice(_:))
//    print("\(count)")
//}

do {
    // It contains a pair of any two letters that appears at least twice in the string without overlapping, like xyxy (xy) or aabcdefgaa (aa), but not like aaa (aa, but it overlaps).
    func hasRepeatingPair(_ string: String) -> Bool {
        var a = string.startIndex
        while true {
            if string.distance(from: a, to: string.endIndex) < 2 {
                return false
            }
            let b = string.index(a, offsetBy: 2)

            let pair = string[a..<b]
            if string.suffix(from: b).contains(pair) {
                return true
            }
            a = string.index(after: a)
        }
    }

    assert(!hasRepeatingPair(""))
    assert(!hasRepeatingPair("a"))
    assert(!hasRepeatingPair("aa"))
    assert(!hasRepeatingPair("aaa"))
    assert(hasRepeatingPair("aaaa"))
    assert(hasRepeatingPair("abab"))
    assert(hasRepeatingPair("abxab"))
    assert(hasRepeatingPair("abxxab"))
    assert(hasRepeatingPair("xabyab"))

    // It contains at least one letter which repeats with exactly one letter between them, like xyx, abcdefeghi (efe), or even aaa.
    func hasRepeatWithSeparator(_ string: String) -> Bool {
        var a = string.startIndex
        while true {
            if string.distance(from: a, to: string.endIndex) < 3 {
                return false
            }
            let b = string.index(a, offsetBy: 2)
            if string[a] == string[b] {
                return true
            }
            a = string.index(after: a)
        }
    }
    assert(!hasRepeatWithSeparator(""))
    assert(!hasRepeatWithSeparator("a"))
    assert(!hasRepeatWithSeparator("aa"))
    assert(hasRepeatWithSeparator("aaa"))
    assert(hasRepeatWithSeparator("aba"))
    assert(!hasRepeatWithSeparator("abcdefga"))
    assert(hasRepeatWithSeparator("abxcxdefg"))
    assert(hasRepeatWithSeparator("abcdefxgx"))

    func isNice(_ string: String) -> Bool {
        return hasRepeatingPair(string) && hasRepeatWithSeparator(string)
    }

    let count = lines.count(where: isNice(_:))
    print("\(count)")
}
