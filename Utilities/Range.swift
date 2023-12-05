//
//  Range.swift
//  day5
//
//  Created by Timothy Wood on 12/5/23.
//

import Foundation


extension Range where Bound : Comparable {

    // Ranges are half open, containing the lower bound, but not upper bound

    func overlaps(_ other: Range) -> Bool {
        if lowerBound == other.lowerBound {
            return true
        }

        if lowerBound < other.lowerBound {
            // == here would not overlap since the upper bound isn't in the range
            return upperBound > other.lowerBound
        } else {
            // again, == wouldn't overlap
            return lowerBound < other.upperBound
        }
    }

}

