//
//  Input.swift
//
//  Created by Timothy Wood on 11/26/22.
//

import Foundation

enum Input {
    static func lines(file: String = #file) -> [String] {
        let processName = ProcessInfo().processName
        let source = URL(fileURLWithPath: file)
        let base = source.deletingLastPathComponent().deletingLastPathComponent()
        let inputURL = base.appendingPathComponent(processName).appendingPathComponent("input.txt")

        let inputData = try! Data(contentsOf: inputURL, options: [])
        return String(data: inputData, encoding: .utf8)!.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
    }
}
