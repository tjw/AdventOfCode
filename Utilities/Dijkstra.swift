//
//  Dijkstra.swift
//  day9
//
//  Created by Timothy Wood on 12/4/24.
//

import Foundation

class Dijkstra<Element: Hashable> {

    private class Node {
        let element: Element
        var edges = [Edge]()

        init(element: Element) {
            self.element = element
        }

        func addEdge(destination: Element, cost: Int) {
            edges.append(Edge(destination: destination, cost: cost))
        }
    }

    private struct Edge {
        let destination: Element
        let cost: Int
    }

    private let nodes: [Node]
    private let elementToIndex: [Element:Int]

    init(elements: [Element]) {
        self.nodes = elements.map { Node(element: $0) }

        var elementToIndex = [Element:Int]()

        elements.enumerated().forEach { idx, element in
            assert(elementToIndex[element] == nil, "Elements must not be repeated")
            elementToIndex[element] = idx
        }
        self.elementToIndex = elementToIndex
    }


    func addEdge(from: Element, to destination: Element, cost: Int) {
        let idx = elementToIndex[from]!
        let node = nodes[idx]
        node.addEdge(destination: destination, cost: cost)
    }

    private class Estimate {
        let element: Element
        var cost: Int
        var predecesor: Estimate?

        init(element: Element) {
            self.element = element
            self.cost = Int.max
            self.predecesor = nil
        }
    }

    func shortestPath(start: Element) -> [Element] {
        fatalError()
    }
}
