//
//  BinarySearchTree.swift
//  Voronoi
//
//  Created by Tate on 2020-07-09.
//  Copyright © 2020 Tate Liang. All rights reserved.
//

import Foundation

/**
 A BST that defines the beach line.
 */
class BeachNode {
    
    /**
     The data stored in each node.
     - breakpoint: A point between two parabolas, traces along an edge.
     - parabola: A leaf node defining a frontier of the beach line.
     */
    enum Data {
        case breakpoint(sites: (Coordinate, Coordinate), edge: HalfEdge?)
        case parabola(site: Coordinate, circleEvent: Event?)
        
        //convenience for variables getting values
        var parabolaSite: Coordinate? {
            get {
                guard case .parabola(site: let p, _) = self else { return nil }
                return p
            }
        }
        var breakpointSites: (Coordinate, Coordinate)? {
            get {
                guard case .breakpoint(sites: let s, _) = self else { return nil }
                return s
            }
        }
        var parabolaCircleEvent: Event? {
            get {
                guard case .parabola(_, circleEvent: let e) = self else { return nil }
                return e
            }
            set {
                guard case .parabola(site: let site, circleEvent: _) = self else { return }
                self = .parabola(site: site, circleEvent: newValue)
            }
        }
        var breakpointEdge: HalfEdge? {
            get {
                guard case .breakpoint(_, edge: let e) = self else { return nil }
                return e
            }
            set {
                guard case .breakpoint(sites: let s, edge: _) = self else { return }
                self = .breakpoint(sites: s, edge: newValue)
            }
        }
        var isParabola: Bool {
            if case .parabola = self { return true }
            return false
        }
        
        //updating one or both breakpoint sites.
        mutating func updateBreakpointSites(left: Coordinate? = nil, right: Coordinate? = nil) {
            guard case .breakpoint(sites: let original, edge: let e) = self else { return }
            if let leftSite = left, let rightSite = right {
                self = .breakpoint(sites: (leftSite, rightSite), edge: e)
            }else if let leftSite = left {
                self = .breakpoint(sites: (leftSite, original.1), edge: e)
            }else if let rightSite = right {
                self = .breakpoint(sites: (original.0, rightSite), edge: e)
            }
        }
    }
    
    var data: Data
    var isLeaf: Bool { data.isParabola }
    
    //BST Variables
    var leftChild: BeachNode?
    var rightChild: BeachNode?
    weak var parent: BeachNode?
    
    
    
        //MARK: - Setup Values
    
    init(_ value: Data) {
        self.data = value
    }
    
    /**
     Add a left and right child to this node.
     - Must add both at once because we do not allow nodes with only one child.
     */
    func adopt(leftChild: BeachNode, rightChild: BeachNode) {
        self.leftChild = leftChild
        self.rightChild = rightChild
        leftChild.parent = self
        rightChild.parent = self
    }
    
    /**
     Replaces this node with a newNode.
     - The newNode has its parent pointer updated.
     - If the replaced node is a root, instead of rewiring pointers, the root's data is replaced with the newNode's data.
        This also means that the newNode will not be up to date with the tree, use the root directly in this case.
     - Parameter newNode: A reference to the node which will replace this one.
     */
    func replace(with newNode: BeachNode) {
        if parent != nil { //we are not a root
            newNode.parent = parent
            
            if isLeftChild() {
                parent?.leftChild = newNode
            }else if isRightChild() {
                parent?.rightChild = newNode
            }
        }else { //we are a root
            leftChild = newNode.leftChild
            rightChild = newNode.rightChild
            data = newNode.data
            
            newNode.leftChild?.parent = self
            newNode.rightChild?.parent = self
        }
    }
    
    
    
    //MARK: - Primitives
    /**
     Computes the smallest key in subtree rooted by this node
     - Guaranteed to be a leaf.
     - Performance: O(log n)
     */
    private func minimum() -> BeachNode {
        var currentNode: BeachNode = self
        while let currentLeftChild = currentNode.leftChild {
            currentNode = currentLeftChild
        }
        return currentNode
    }
    /**
    Computes the largest key in subtree rooted by this node
    - Guaranteed to be a leaf.
    - Performance: O(log n)
    */
    private func maximum() -> BeachNode {
        var currentNode: BeachNode = self
        while let currentRightChild = currentNode.rightChild {
            currentNode = currentRightChild
        }
        return currentNode
    }
    
    func isLeftChild() -> Bool {
        return self.parent?.leftChild === self
    }
    func isRightChild() -> Bool {
        return self.parent?.rightChild === self
    }
    
    /**
     Computes the largest key smaller than this node's key in this node's subtree.
     - Guaranteed to be a leaf.
     - Performance: O(log n)
     */
    func predecessor() -> BeachNode? {
        if let left = leftChild {
            return left.maximum()
        }
        
        //traverse parent pointers until we are right child
        var currentNode = self
        while currentNode.parent != nil && currentNode.isLeftChild() {
            currentNode = currentNode.parent!
        }
        
        //make sure there is a left child
        if let leftCousin = currentNode.parent?.leftChild {
            return leftCousin.maximum()
        }else {
            return nil
        }
    }
    
    /**
     Computes the smallest key larger than this node's key in this node's subtree.
     - Guaranteed to be a leaf.
     - Performance: O(log n)
     */
    func successor() -> BeachNode? {
        if let right = rightChild {
            return right.minimum()
        }
        
        //traverse parent pointers until we are left child
        var currentNode = self
        while currentNode.parent != nil && currentNode.isRightChild() {
            currentNode = currentNode.parent!
        }
        
        //make sure there is a right child
        if let rightCousin = currentNode.parent?.rightChild {
            return rightCousin.minimum()
        }else {
            return nil
        }
    }
    
    
    
    //MARK: - Beach Line Functions
    
    /**
     Finds the parabola containing the x coordinate of the given point.
     - Returns: The BeachNode(data = parabola) that is above it, or nil if a breakpoint fails to be computed.
     - Performance: O(log n)
     */
    func findParabola(above coordinate: Coordinate) -> BeachNode? {
        let key = coordinate.x
        let sweepLine = coordinate.y
        var currentNode: BeachNode = self
        while !currentNode.isLeaf {
            //breakpoint should exist
            guard let breakpoint = currentNode.data.calcBreakpoint(sweepLine: sweepLine) else { return nil }
            
            //degenerate event where the x value exactly matches a breakpoint
            if key == breakpoint.x {
                return leftChild != nil ? leftChild!.maximum() : rightChild?.minimum()
            
            //binary search
            }else if key < breakpoint.x {
                guard let currentLeftChild = currentNode.leftChild else { return nil }
                currentNode = currentLeftChild
            }else {
                guard let currentRightChild = currentNode.rightChild else { return nil }
                currentNode = currentRightChild
            }
        }
        return currentNode
    }
    
    /**
     Searches the subtree for a breakpoint between the specified parabolas.
     - Parameter parabolas: A tuple of the two parabolas the breakpoint separates (must be in correct order)
     - Parameter sweepLine: The current position of the sweep line.
     - Performance: O(log n)
     */
    func getBreakpointNode(between parabolas: (BeachNode, BeachNode), sweepLine: Double) -> BeachNode? {
        guard let parabolaSiteA = parabolas.0.data.parabolaSite else { return nil }
        guard let parabolaSiteB = parabolas.1.data.parabolaSite else { return nil }

        let query = BeachNode(.breakpoint(sites: (parabolaSiteA, parabolaSiteB), edge: nil))
        guard let queryBreakpoint = query.data.calcBreakpoint(sweepLine: sweepLine) else { return nil }
        
        var currentNode: BeachNode? = self
        
        while let node = currentNode {
            guard !node.isLeaf else { return nil }
            
            guard let nodeBreakpoint = node.data.calcBreakpoint(sweepLine: sweepLine) else { return nil }
            
            //Binary search
            if queryBreakpoint.x == nodeBreakpoint.x {
                return node
            }else if queryBreakpoint.x < nodeBreakpoint.x {
                currentNode = node.leftChild
            }else {
                currentNode = node.rightChild
            }
        }
        return nil
    }
}



//MARK: - Debug

extension BeachNode: CustomStringConvertible {
    var description: String {
        switch data {
        case .breakpoint(sites: let sites, edge: _):
            return "B\(sites)"
        case .parabola(site: let site, circleEvent: _):
            return "P\(site)"
        }
    }
}
