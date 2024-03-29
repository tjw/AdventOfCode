//
//  Grid.swift
//  day12
//
//  Created by Timothy Wood on 12/11/22.
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

class GridMap<Element> {

    typealias Location = Location2D

    var elements: [[Element]]
    var width: Int
    var height: Int

    convenience init(lines: [String], transform: (Location2D, Character) -> Element) {
        var rows = [[Element]]()

        for y in 0..<lines.count {
            var elements = [Element]()
            var line = lines[y][...]
            for x in 0..<line.count {
                let ch = line.first!
                line = line.dropFirst()
                let element = transform(Location2D(x: x, y: y), ch)
                elements.append(element)
            }
            rows.append(elements)
        }

        self.init(elements: rows)
    }

    init(elements: [[Element]]) {
        self.elements = elements
        self.height = elements.count
        self.width = elements[0].count

        elements.forEach { assert($0.count == self.width) }
    }

    func contains(location: Location) -> Bool {
        if location.x < 0 || location.x >= width || location.y < 0 || location.y >= height {
            return false
        }
        return true
    }

    subscript(location: Location) -> Element? {
        get {
            guard contains(location: location) else { return nil }
            return elements[location.y][location.x]
        }
        set {
            guard contains(location: location) else { fatalError() }
            elements[location.y][location.x] = newValue!
        }
    }

    func forEach(_ operation: (Location, Element) -> Void) {
        (0..<height).forEach { y in
            (0..<width).forEach { x in
                operation(Location(x: x, y: y), elements[y][x])
            }
        }
    }

    func forEachRow(_ operation: (Int, [Element]) -> Void) {
        (0..<height).forEach { y in
            operation(y, elements[y])
        }
    }

    func row(y: Int) -> [Element] {
        assert(y < height)
        return elements[y]
    }
    
    func insert(row: [Element], at y: Int) {
        assert(row.count == width)
        assert(y <= height)

        elements.insert(row, at: y)
        height += 1
    }

    func column(x: Int) -> [Element] {
        assert(x < width)
        return elements.compactMap { $0[x] }
    }

    func insert(column: [Element], at x: Int) {
        assert(column.count == height)
        assert(x <= width)

        for y in 0..<height {
            elements[y].insert(column[y], at: x)
        }
        width += 1
    }

    func expandToInclude(location: Location, content: Element) {
        guard !contains(location: location) else { return }

        let extraWidth = location.x - width + 1
        if extraWidth > 0 {
            for y in 0..<height {
                elements[y] = elements[y] + Array(repeating: content, count: extraWidth)
            }
            width += extraWidth
        }

        let extraHeight = location.y - height + 1
        if extraHeight > 0 {
            (0..<extraHeight).forEach { _ in
                elements.append(Array(repeating: content, count: width))
            }
            height += extraHeight
        }

        print("width \(width), height \(height)")
    }

    func writeImage(prefix: String, number: Int, flipped: Bool, makePixel: (Element) -> RGB) {
        let rows = flipped ? elements.reversed() : elements

        var pixelData = Data()
        for row in rows {
            for column in row {
                var pixel = makePixel(column)
                pixelData.append(&pixel.r, count: 1)
                pixelData.append(&pixel.g, count: 1)
                pixelData.append(&pixel.b, count: 1)
            }
        }

        let name = String(format: "%@-%05d.png", prefix, number)
        let url = URL(filePath: NSTemporaryDirectory()).appending(component: name)
        print("url \(url.absoluteString)")

        let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, [:] as CFDictionary)!

        let provider = CGDataProvider(data: pixelData as CFData)!
        let image = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 24, bytesPerRow: width*3, space: CGColorSpace(name: CGColorSpace.genericRGBLinear)!, bitmapInfo: CGBitmapInfo(), provider: provider, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)!

        CGImageDestinationAddImage(dest, image, nil)
        CGImageDestinationFinalize(dest)
    }
}

protocol GridCharacter {
    var character: Character { get }
}

extension GridMap where Element : GridCharacter {

    var stringRepresentation: String {
        elements.map { row in
            String(row.map(\.character))
        }.joined(separator: "\n")
    }
}

