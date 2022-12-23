//
//  HashMap.swift
//  day14
//
//  Created by Timothy Wood on 12/15/22.
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

// Unlike GridMap, this is infinite and can have negative coordinates

class HashMap2D<Element> {

    typealias Location = Location2D
    typealias Bounds = Bounds2D

    private(set) var elements: [Location:Element]

    let defaultElement: Element

    init(defaultElement: Element) {
        self.elements = [:]
        self.defaultElement = defaultElement
    }

    subscript(location: Location) -> Element {
        get {
            return elements[location] ?? defaultElement
        }
        set {
            elements[location] = newValue
        }
    }

    func clear(location: Location) {
        elements.removeValue(forKey: location)
    }

    var bounds: Bounds {
        guard !elements.isEmpty else { return Bounds(x: 0, y: 0, width: 0, height: 0) }

        var minLocation = elements.first!.key
        var maxLocation = minLocation

        elements.forEach { location, _ in
            minLocation.x = min(minLocation.x, location.x)
            minLocation.y = min(minLocation.y, location.y)
            maxLocation.x = max(maxLocation.x, location.x)
            maxLocation.y = max(maxLocation.y, location.y)
        }

        return Bounds(x: minLocation.x, y: minLocation.y, width: maxLocation.x - minLocation.x + 1, height: maxLocation.y - minLocation.y + 1)
    }

    // Compute the bounds of the map and then call the given operation on each location inside that bounds
    func forEach(_ operation: (Location, Element) -> Void) {
        let bounds = self.bounds
        for y in (bounds.y..<bounds.y+bounds.height) {
            for x in (bounds.x..<bounds.x+bounds.width) {
                let location = Location(x: x, y: y)
                operation(location, elements[location] ?? defaultElement)
            }
        }
    }

    func writeImage(prefix: String, number: Int, flipped: Bool, makePixel: (Element) -> RGB) {
        let bounds = self.bounds

        var pixelData = Data()
        forEach { Location, element in
            var pixel = makePixel(element)
            pixelData.append(&pixel.r, count: 1)
            pixelData.append(&pixel.g, count: 1)
            pixelData.append(&pixel.b, count: 1)
        }

        let name = String(format: "%@-%05d.png", prefix, number)
        let url = URL(filePath: NSTemporaryDirectory()).appending(component: name)
        print("url \(url.absoluteString)")

        let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, [:] as CFDictionary)!

        let provider = CGDataProvider(data: pixelData as CFData)!
        let image = CGImage(width: bounds.width, height: bounds.height, bitsPerComponent: 8, bitsPerPixel: 24, bytesPerRow: bounds.width*3, space: CGColorSpace(name: CGColorSpace.genericRGBLinear)!, bitmapInfo: CGBitmapInfo(), provider: provider, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)!

        CGImageDestinationAddImage(dest, image, nil)
        CGImageDestinationFinalize(dest)
    }
}
