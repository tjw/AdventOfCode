//
//  RandomAccessCollection.swift
//  day5
//
//  Created by Timothy Wood on 12/5/23.
//

import Foundation

extension RandomAccessCollection {

    // https://stackoverflow.com/questions/31904396/swift-binary-search-for-standard-array/33674192#33674192

    /// Finds such index N that predicate is true for all elements up to
    /// but not including the index N, and is false for all elements
    /// starting with index N.
    /// Behavior is undefined if there is no such N.
    func binarySearch(predicate: (Element) -> Bool) -> Index {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high)/2)
            if predicate(self[mid]) {
                low = index(after: mid)
            } else {
                high = mid
            }
        }
        return low
    }

    func insertionIndex(_ element: Element, isOrderedBefore: (Element, Element) -> Bool) -> Index {
        binarySearch(predicate: { isOrderedBefore($0, element) })
    }

}

extension Array where Element : Comparable {

    mutating
    func insertInSortedOrder(_ element: Element) where Element : Comparable {
        let index = insertionIndex(element, isOrderedBefore: { $0 < $1 })
        insert(element, at: index)
    }
    
}
