//
//  Input.swift
//
//  Created by Timothy Wood on 11/26/22.
//

import Foundation

enum Input {
    static func lines(includeEmpty: Bool = false, file: String = #file) -> [String] {
        let processName = ProcessInfo().processName
        let source = URL(fileURLWithPath: file)
        let base = source.deletingLastPathComponent().deletingLastPathComponent()
        let inputURL = base.appendingPathComponent(processName).appendingPathComponent("input.txt")

        let inputData = try! Data(contentsOf: inputURL, options: [])
        return String(data: inputData, encoding: .utf8)!.split(separator: "\n", omittingEmptySubsequences: !includeEmpty).map { String($0) }
    }
}

extension String {
    var trailingNumber: Int {
        let digits = self.reversed().prefix(while: \.isNumber).reversed()
        return Int(String(digits))!
    }

    func numbers(separatedBy characterSet: CharacterSet = CharacterSet.whitespaces) -> [Int] {
        let components = self.components(separatedBy: characterSet)
        return components.compactMap { Int($0) }
    }
}
