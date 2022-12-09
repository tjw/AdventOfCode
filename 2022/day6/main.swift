//
//  main.swift
//  day6
//
//  Created by Timothy Wood on 12/9/22.
//

import Foundation

let input = Input.lines().first!

func offsetOfUniqueRun(length run: Int) -> Int {
    var characters = input.map { $0 as Character }
    var offset = run
    var buffer = characters[0..<run]
    characters = Array(characters.dropFirst(run))

    while Set(buffer).count != run {
        offset += 1
        buffer = Array(buffer.dropFirst()) + [characters.first!]
        characters = Array(characters.dropFirst())
    }
    return offset
}

let packet = offsetOfUniqueRun(length: 4)
print("\(packet)")
assert(packet == 1235)

let message = offsetOfUniqueRun(length: 14)
print("\(message)")
assert(message == 3051)
