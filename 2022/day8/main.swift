//
//  main.swift
//  day8
//
//  Created by Timothy Wood on 12/9/22.
//

import Foundation

class Tree {
    let height: Int
    var visible: Bool = false

    init(height: Int) {
        self.height = height
    }
}

let grid = Input.lines().map { line in
    line.map {
        Tree(height: Int(String($0))!)
    }
}

do {
    func process(row: [Tree]) {
        // Passing -1 to make zero height trees on the border visible
        _ = row.reduce(-1) { heightToFar, tree in
            if tree.height > heightToFar {
                tree.visible = true
                return tree.height
            }
            return heightToFar
        }
    }

    // Left and right
    grid.forEach { row in
        process(row: row)
        process(row: row.reversed())
    }

    func matrixTranspose<T>(_ matrix: [[T]]) -> [[T]] {
        if matrix.isEmpty {return matrix}
        var result = [[T]]()
        for index in 0..<matrix.first!.count {
            result.append(matrix.map{$0[index]})
        }
        return result
    }

    // Up and down
    let transposed = matrixTranspose(grid)
    transposed.forEach { row in
        process(row: row)
        process(row: row.reversed())
    }

    let visibleCount = grid.reduce(0) { partialResult, trees in
        return partialResult + trees.reduce(0, { $0 + ($1.visible ? 1 : 0) })
    }
    print("\(visibleCount)")
    assert(visibleCount == 1818)
}

do {
    // Doing the exponental version for scenic score. Unclear whether it will matter.

    let gridHeight = grid.count
    let gridWidth = grid[0].count

    func score(x: Int, y: Int, dx: Int, dy: Int) -> Int {
        var score = 0
        let height = grid[y][x].height

        var nx = x, ny = y
        while true {
            nx += dx
            ny += dy
            if nx < 0 || nx >= gridWidth || ny < 0 || ny >= gridHeight {
                break
            }
            score += 1
            let next = grid[ny][nx].height
            if next >= height {
                break
            }
        }
        return score
    }

    func scoreAt(x: Int, y: Int) -> Int {
        let left = score(x: x, y: y, dx: -1, dy: 0)
        let right = score(x: x, y: y, dx: 1, dy: 0)
        let up = score(x: x, y: y, dx: 0, dy: -1)
        let down = score(x: x, y: y, dx: 0, dy: 1)
        return left*right*up*down
    }

    var bestScore = 0
    (0..<gridHeight).forEach { y in
        (0..<gridWidth).forEach { x in
            let score = scoreAt(x: x, y: y)
            if score > bestScore {
                bestScore = score
            }
        }
    }

    print("\(bestScore)")
    assert(bestScore == 368368)
}
