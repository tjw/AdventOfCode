//
//  main.swift
//  day7
//
//  Created by Timothy Wood on 12/9/22.
//

import Foundation

struct File {
    let name: String
    let size: Int
}

class Directory {
    weak var parent: Directory?
    let name: String
    var files: [String:File]
    var children: [String:Directory]

    private init() {
        self.parent = nil
        self.name = ""
        self.files = [:]
        self.children = [:]
    }

    static func root() -> Directory {
        Directory()
    }

    init(parent: Directory, name: String) {
        self.parent = parent
        self.name = name
        self.files = [:]
        self.children = [:]
    }

    // Could probably write a nifty bottom up reducer, but...
    var totalSize = 0

    func updateTotalSizes() -> Int {
        var size = 0
        children.forEach { size += $0.value.updateTotalSizes() }
        size += files.reduce(0, { $0 + $1.value.size })
        totalSize = size
        return size
    }

    func eachDirectory(_ operation: (Directory) -> Void) {
        operation(self)
        children.forEach { $0.value.eachDirectory(operation) }
    }

}

let root = Directory.root()
var pwd = root

// Not bothering to keep track of what the currently running command is, just assuming that ls output will only show up when relevant
Input.lines().forEach { line in
    if line.hasPrefix("$ cd ") {
        let name = String(line.dropFirst(5))
        if name == "/" {
            pwd = root
        } else if name == ".." {
            pwd = pwd.parent!
        } else {
            pwd = pwd.children[name]!
        }
    } else if line == "$ ls" {
        // Ignored as above
    } else {
        // ls output
        // Not keeping directory and file names disjoint, assuming the input is good
        let components = line.split(separator: " ")
        let name = String(components[1])
        if components[0] == "dir" {
            let child = Directory(parent: pwd, name: name)
            assert(pwd.children[name] == nil)
            pwd.children[name] = child
        } else {
            let size = Int(components[0])!
            let file = File(name: name, size: size)
            assert(pwd.files[name] == nil)
            pwd.files[name] = file
        }
    }
}

let spaceUsed = root.updateTotalSizes()


do {
    var result = 0
    root.eachDirectory { dir in
        if dir.totalSize <= 100000 {
            result += dir.totalSize
        }
    }
    print("\(result)")
    assert(result == 1792222)
}

do {
    let freeSpace = 70000000 - spaceUsed
    print("freeSpace \(freeSpace)")

    var best: Directory? = nil
    root.eachDirectory { dir in
        if dir.totalSize + freeSpace >= 30000000 {
            if let current = best {
                if current.totalSize > dir.totalSize {
                    best = dir
                }
            } else {
                best = dir
            }
        }
    }
    print("\(best!.totalSize)")
    assert(best!.totalSize == 1112963)
}
