//
//  MinHeap.swift
//  AdventOfCode-2015
//
//  Created by Timothy Wood on 12/4/24.
//

import Foundation

// A simpler heap than than the Min-Max heap, but aiming to be able to change values and update indexes in elemenets to facilitate this. See "Introduction to Algorithms" (Thomas H. Cormen, et. al.)

private func parent(_ i: Int) -> Int {
    assert(i >= 0)
    return (i - 1)/2
}
private func leftChild(_ i: Int) -> Int {
    assert(i >= 0)
    return (i * 2) + 1
}
private func rightChild(_ i: Int) -> Int {
    assert(i >= 0)
    return (i * 2) + 2
}

struct Heap<Element: Comparable> {

    private var contents: ContiguousArray<Element>
    private let isBefore: (Element, Element) -> Bool

    init(elements: [Element], isBefore: @escaping (Element, Element) -> Bool) {
        self.contents = []
        self.isBefore = isBefore

        // Could re-order in place, espanding the heapness one spot at a time
        elements.forEach { insert($0) }
    }

    mutating func insert(_ element: Element) {
        let index = contents.count
        contents.append(element)
        pushUp(element: element, at: index)
        checkInvariants()
    }

    var isEmpty: Bool {
        return contents.isEmpty
    }

    mutating func removeFirst() -> Element {
        let result = contents.first!

        let count = contents.count

        if count == 1 {
            // This was the last item and there it nothing needed to do to fix the heap
            contents.remove(at: 0)
        } else {
            // Move the last item to occupy the first position
            let lastIndex = count - 1
            let last = contents[lastIndex]
            contents.remove(at: lastIndex)

            contents[0] = last
            pushDown(element: last, at: 0, count: lastIndex)
        }
        checkInvariants()

        return result
    }

    // Repeatedly move the item at the given index up a level until it is no longer needed or is at the root
    private mutating func pushUp(element: Element, at index: Int) {
        if (index == 0) {
            return // Already at the root
        }
        assert(contents[index] == element)
        let parentIndex = parent(index)
        let parent = contents[parentIndex]

        if isBefore(parent, element) {
            // No more moves needed
            return
        }

        // Swap the elements and try again with the element now at what was its parent
        contents.swapAt(index, parentIndex)
        pushUp(element: element, at: parentIndex)
    }

    // Repeatedly push the item now at the root until the heap condition is restored.
    // That is at each position, the parent must be `before` its children (if they exist). So, when picking which (if either) child to swap with, we have to pick the one of them that should go first, lest it invalidate the heap condition too.
    private mutating func pushDown(element: Element, at index: Int, count: Int) {
        assert(contents[index] == element)
        assert(contents.count == count)

        // Start assuming we'll leave the item where it is
        var destinationIndex = index
        var destination = element

        // Check the left child first for an early out
        let leftIndex = leftChild(index)
        if leftIndex >= count {
            // The left child is out of bounds, so we can't move the item down any further (since the left child not existing implies the right one doesn't either
            return
        }
        let left = contents[leftIndex]
        if isBefore(left, element) {
            destinationIndex = leftIndex
            destination = left
        }

        // Now, if there is a right child, check it vs our provisional destination (maybe the original parent, maybe the left child)
        let rightIndex = rightChild(index)
        if rightIndex < count {
            let right = contents[rightIndex]
            if isBefore(right, destination) {
                destinationIndex = rightIndex
                destination = right
            }
        }

        if destinationIndex == index {
            // No movement needed
            return
        }

        // Try pushing down again from the new location
        contents.swapAt(index, destinationIndex)

        pushDown(element: element, at: destinationIndex, count: count)
    }

    private func checkInvariants() {
        for index in 0..<contents.count {
            if index == 0 {
                continue
            }

            // The reversed check here is intentional. The parent does not have to be `isBefore` the child. But the child *cannot* be before the parent. Consider the case of inserting the same value multiple times.
            let parent = contents[parent(index)]
            let child = contents[index]
            assert(!isBefore(child, parent))
        }
    }
}
