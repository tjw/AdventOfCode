//
//  main.swift
//  day9
//
//  Created by Timothy Wood on 12/8/24.
//

import Foundation

do {
    struct Block {
        let fileID: Int?

        // Only really works on the test input with fileID going up to 9
        var stringRepresentation: String {
            if let fileID {
                return "\(fileID)"
            } else {
                return "."
            }
        }
    }

    var blocks: [Block] = []

    let input = Input.input().trimmingCharacters(in: .whitespacesAndNewlines )
    do {
        var fileID = 0
        var isBlock = true
        input.forEach { ch in
            let length = Int(String(ch))!
            if isBlock {
                let block = Block(fileID: fileID)
                blocks.append(contentsOf: Array(repeating: block, count: length))
                fileID += 1
            } else {
                let block = Block(fileID: nil)
                blocks.append(contentsOf: Array(repeating: block, count: length))
            }
            isBlock = !isBlock
        }
    }

    //print("\(String(blocks.flatMap { $0.stringRepresentation }))")

    let count = blocks.count
    var firstIndex = 0
    var lastIndex = blocks.count - 1

    while true {
        // Step first index forward looking for an empty block
        while firstIndex < count && blocks[firstIndex].fileID != nil {
            firstIndex += 1
        }
        if firstIndex >= count {
            break
        }

        // Step lastIndex backward for a non-empty block
        while lastIndex > 0 && blocks[lastIndex].fileID == nil {
            lastIndex -= 1
        }
        if lastIndex < 0 {
            break
        }
        if lastIndex <= firstIndex {
            break
        }

        // Swap the blocks
        //    print("swap \(firstIndex) and \(lastIndex)")
        blocks.swapAt(firstIndex, lastIndex)

        //    print("\(String(blocks.flatMap { $0.stringRepresentation }))")
    }

    var checksum = 0
    for blockIndex in 0..<blocks.count {
        checksum += blockIndex * (blocks[blockIndex].fileID ?? 0)
    }
    print("\(checksum)")
    assert(checksum == 6360094256423)
}


// For part 2, re-read the input, but keep it in terms of spans
do {
    struct Span {
        var fileID: Int?
        var length: Int

        // Only really works on the test input with fileID going up to 9
        var stringRepresentation: String {
            if let fileID {
                var result = ""
                (0..<length).forEach { _ in
                    result.append("\(fileID)")
                }
                return result
            } else {
                var result = ""
                (0..<length).forEach { _ in
                    result.append(".")
                }
                return result
            }
        }
    }
    var spans = [Span]()

    let input = Input.input().trimmingCharacters(in: .whitespacesAndNewlines )
    do {
        var fileID = 0
        var isFile = true
        input.forEach { ch in
            let length = Int(String(ch))!
            if isFile {
                assert(length > 0)
                let span = Span(fileID: fileID, length: length)
                spans.append(span)
                fileID += 1
            } else {
                if length > 0 {
                    let span = Span(fileID: nil, length: length)
                    spans.append(span)
                }
            }
            isFile = !isFile
        }
    }
    //print("\(String(spans.flatMap { $0.stringRepresentation }))")

    let count = spans.count
    var firstIndex = 0
    var lastIndex = count - 1

    // For this version we don't always step firstIndex forward. Instead it is the index of the first empty span. This is where we can start searching for one that is big enough.
    while true {
        // Look backwards for the next non-empty span.
        while lastIndex >= 0 {
            if spans[lastIndex].fileID == nil {
                lastIndex -= 1
            } else {
                break
            }
        }

        // Look forward to the first empty span
        while firstIndex < count {
            if spans[firstIndex].fileID != nil {
                firstIndex += 1
            } else {
                break
            }
        }


        if lastIndex <= firstIndex {
            break
        }

        let file = spans[lastIndex]
        //print("trying \(file.fileID!)")

        // Look forward from firstIndex to the first empty span that can hold this file
        let destinationIndex = (firstIndex..<lastIndex).first { spanIndex in
            let candidate = spans[spanIndex]
            return candidate.fileID == nil && candidate.length >= file.length
        }
        if let destinationIndex {
            // Found a slot.
            //print("  destinationIndex \(destinationIndex)")

            let available = spans[destinationIndex].length
            let extra = available - file.length
            //print("  extra \(extra)")

            if extra > 0 {
                // If there is extra space, we need to split the span. Trim the empty one and move the file to just before it
                spans[destinationIndex].length = extra
                spans.insert(file, at: destinationIndex)

                // This shifts the length of the spans
                lastIndex += 1
            } else {
                // Otherwise, it exactly fits
                assert(extra == 0)
                spans[destinationIndex] = file
            }

            // We don't bother compacting the trailing empty spans of moved files, which would just complicate the index math more and doesn't matter for the checksum or continuing the search
            spans[lastIndex].fileID = nil
        } else {
            //print("  cannot be moved")
            lastIndex -= 1
        }

        //print("\(String(spans.flatMap { $0.stringRepresentation }))")
    }

    var checksum = 0
    var blockIndex = 0
    for span in spans {
        if let fileID = span.fileID {
            (0..<span.length).forEach { _ in
                checksum += fileID * blockIndex
                blockIndex += 1
            }
        } else {
            blockIndex += span.length
        }
    }
    print("\(checksum)")
    assert(checksum == 6379677752410)
}
