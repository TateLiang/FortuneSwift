//
//  PriorityQueue.swift
//  Voronoi
//
//  Created by Tate on 2020-07-09.
//  Copyright © 2020 Tate Liang. All rights reserved.
//
/**
 Priority queue data structure based on heap
 - Performance: O(log n) enqueue/dequeue, O(n) deletion.
*/
public struct PriorityQueue<T> {
    fileprivate var heap: Heap<T>
    
    public init(sort: @escaping (T, T) -> Bool) {
        heap = Heap(sort: sort)
    }
    public init(array: [T], sort: @escaping (T, T) -> Bool) {
        heap = Heap(array: array, sort: sort)
    }
    public var isEmpty: Bool {
        return heap.isEmpty
    }
    
    public mutating func enqueue(_ element: T) { heap.insert(element) }
    public mutating func dequeue() -> T? { heap.remove() }
}

extension PriorityQueue where T: Equatable {
    public func index(of element: T) -> Int? {
        return heap.index(of: element)
    }
    
    @discardableResult public mutating func remove(node: T) -> T? {
        if let index = heap.index(of: node) {
            return heap.remove(at: index)
        }
        return nil
    }
}

