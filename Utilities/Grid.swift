//
//  Grid.swift
//  day12
//
//  Created by Timothy Wood on 12/11/22.
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

class Map<Element> {

    var elements: [[Element]]
    var width: Int
    var height: Int

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

    struct RGB {
        var r: UInt8
        var g: UInt8
        var b: UInt8
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
