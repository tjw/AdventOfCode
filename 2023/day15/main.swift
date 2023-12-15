//
//  main.swift
//  day15
//
//  Created by Timothy Wood on 12/14/23.
//

import Foundation

let lines = Array(Input.lines())


func hash(_ string: String) -> Int {
    var result = 0
    for ch in string {
        result += Int(ch.asciiValue!)
        result *= 17
        result %= 256
    }
    return result
}

do {
    var result = 0
    for line in lines {
        for instruction in line.components(separatedBy: ",") {
            result += hash(instruction)
        }
    }
    print("\(result)")
    assert(result == 516469)
}


struct Lens {
    let label: String
    let focalLength: Int
}

class Box {
    var lenses = [Lens]()
}

do {
    let boxes = (0..<256).map { _ in Box() }
    let instructionRegex = /([a-z]+)([-=])([0-9]*)/

    for line in lines {
        for instruction in line.components(separatedBy: ",") {
            let match = try! instructionRegex.firstMatch(in: instruction)!
            let label = String(match.1)
            let operation = match.2

            let labelHash = hash(label)
            let box = boxes[labelHash]

            if operation == "=" {
                let lens = Lens(label: label, focalLength: Int(match.3)!)
                if let existingIndex = box.lenses.firstIndex(where: { $0.label == label }) {
                    box.lenses[existingIndex] = lens
                } else {
                    box.lenses.append(lens)
                }
            } else if operation == "-" {
                if let existingIndex = box.lenses.firstIndex(where: { $0.label == label }) {
                    box.lenses.remove(at: existingIndex)
                }
            } else {
                fatalError()
            }

//            print("After \"\(instruction)\":")
//            for boxIndex in 0..<256 {
//                let box = boxes[boxIndex]
//                if !box.lenses.isEmpty {
//                    print("Box \(boxIndex):", terminator: "")
//                    for lens in box.lenses {
//                        print(" [\(lens.label) \(lens.focalLength)]", terminator: "")
//                    }
//                    print("")
//                }
//            }
        }
    }

    var result = 0
    for boxIndex in 0..<256 {
        let box = boxes[boxIndex]
        for lensIndex in 0..<box.lenses.count {
            let lens = box.lenses[lensIndex]
            let power = (boxIndex + 1) * (lensIndex + 1) * lens.focalLength
            //print("\(lens.label): box \(boxIndex), lens \(lensIndex), focal length \(lens.focalLength) -> \(power)")
            result += power
        }
    }
    print("\(result)")
    assert(result == 221627)
}
