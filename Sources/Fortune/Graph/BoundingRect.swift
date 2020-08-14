//
//  BoundingRect.swift
//  Voronoi
//
//  Created by Tate on 2020-07-09.
//  Copyright © 2020 Tate Liang. All rights reserved.
//

import Foundation

/**
 Rectangle that bounds the edges of a diagram.
 - Note: Can be relatively easily modified to a bounding polygon
 */
struct BoundingRect {
    var x: Double
    var y: Double
    var width: Double
    var height: Double
    
    
    init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    /**
     Checks whether the rectangle contains a point.
     - Variable precision allows for slight innacuracies such as -0.0 == 0.0
     - Outputs false if the point is nil.
     */
    private let containsPrecision: Double = 0.01
    private func contains(_ point: Coordinate?) -> Bool {
        guard let p = point else { return false }
        
        let xCondition = (x - containsPrecision)...(x + width + containsPrecision) ~= p.x
        let yCondition = (y - containsPrecision)...(y + height + containsPrecision) ~= p.y
        return xCondition && yCondition
    }
    private func contains(_ vertex: Vertex?) -> Bool {
        guard let v = vertex else { return false }

        let xCondition = (x - containsPrecision)...(x + width + containsPrecision) ~= v.x
        let yCondition = (y - containsPrecision)...(y + height + containsPrecision) ~= v.y
        return xCondition && yCondition
    }
    
    
    
    //MARK: - Defining Border
    
    /** The vertices that make up the corners of this rect. */
    private var cornerVertices: [Vertex] {[
        Vertex(x: x, y: y),
        Vertex(x: x + width, y: y),
        Vertex(x: x + width, y: y + height),
        Vertex(x: x, y: y + height)
    ]}
    /** The segments that make up the edges of this rect. */
    private var borderSegments: [(Vertex, Vertex)] {[
        (cornerVertices[0], cornerVertices[1]),
        (cornerVertices[1], cornerVertices[2]),
        (cornerVertices[2], cornerVertices[3]),
        (cornerVertices[3], cornerVertices[0]),
    ]}
    
    /** Re-orders the given vertices clockwise based on the center of the rect. */
    private func orderVerticesClockwise(_ vertices: [Vertex]) -> [Vertex] {
        let center = Coordinate(x: x + (width/2), y: y + (height/2))
        return vertices.sorted {
            let a1 = CircleGeometry.getAngle(point: $0.coordinate, center: center)
            let a2 = CircleGeometry.getAngle(point: $1.coordinate, center: center)
            return a1 > a2
        }
    }
    
    
    
    //MARK: - Bounding Edges
    
    /**
     Returns the specified edges bounded by this rect.
     - Parameter edges: The current (unbounded) edges.
     - Parameter vertices: The current vertices (excluding border vertices & including outside vertices)
     - Performance: O(n)
     */
    func boundEdges(edges: [HalfEdge], vertices: [Vertex]) -> (edges: [HalfEdge], vertices: [Vertex]) {
        var updatedEdges: [HalfEdge] = edges
        var borderVertices: [Vertex] = cornerVertices
        var updatedVertices: [Vertex] = vertices
        
        //update all of the edges
        for (index, edge) in updatedEdges.enumerated().reversed() {
            //bound this edge if it has a breakpoint (ie origin comes from infinity), or has an origin outside the bounds
            //note: no need to worry about edges with destination nil/outside bounds as destination == twin.origin
            if edge.breakpoint != nil || !contains(edge.origin) {
                
                if let boundedPoints = boundEdge(edge) { //The edge does intersect with the rect
                    
                    let startBorderVertex = Vertex(boundedPoints.start)
                    
                    edge.breakpoint = nil
                    edge.origin = startBorderVertex
                    
                    startBorderVertex.incidentEdges.append(edge)
                    borderVertices.append(startBorderVertex)
                    
                    //If the end was also bounded
                    if let endBorderPoint = boundedPoints.end {
                        let endBorderVertex = Vertex(endBorderPoint)
                        borderVertices.append(endBorderVertex)

                        if let twin = edge.twin {
                            twin.breakpoint = nil
                            twin.origin = endBorderVertex
                            endBorderVertex.incidentEdges.append(twin)
                        }
                    }
                
                }else { //the edge does not intersect with the rect
                    //recalculates the next/prev pointers
                    deleteEdge(edge)
                    updatedEdges.remove(at: index)
                }
            }
        }
        
        //compute the new edges made from the borderVertices
        borderVertices = orderVerticesClockwise(borderVertices)
        var lastEdge: HalfEdge? //the previous "newEdge1"
        for (index, vertex) in borderVertices.enumerated() { //Assumes borderVertices has at least 2 elements
            
            let nextVertex = borderVertices[borderVertices.indices.contains(index+1) ? index+1 : 0]
            
            if nextVertex.incidentEdges.count == 0 { //nextVertex is a corner
                //Create the new edges from vertex -> nextVertex
                let newEdge1 = HalfEdge(origin: vertex) //outside edge
                let newEdge2 = HalfEdge(origin: nextVertex, twin: newEdge1) //inside edge
                
                //add to updatedEdges
                updatedEdges.append(newEdge1)
                updatedEdges.append(newEdge2)
                
                //update next/prev pointers
                if vertex.incidentEdges.count > 0 {
                    //incident could be inward edge OR previous newEdge2
                    newEdge2.setNext(vertex.incidentEdges[0])
                    if let incidentSite = vertex.incidentEdges[0].incidentSite {
                        newEdge2.setIncidentSite(incidentSite)
                    }
                }
                if let last = lastEdge {
                    last.setNext(newEdge1)
                }
                
                vertex.incidentEdges.append(newEdge1)
                nextVertex.incidentEdges.append(newEdge2)
                
                lastEdge = newEdge1
                
            }else if nextVertex.incidentEdges.count == 1 || nextVertex.incidentEdges.count == 2 { //has an inward edge
                //Create the new edges from vertex -> nextVertex
                let newEdge1 = HalfEdge(origin: vertex) //outside edge
                let newEdge2 = HalfEdge(origin: nextVertex, twin: newEdge1) //inside edge
                if let incidentSite = nextVertex.incidentEdges[0].twin?.incidentSite {
                    newEdge2.setIncidentSite(incidentSite)
                }
                
                //add to updatedEdges
                updatedEdges.append(newEdge1)
                updatedEdges.append(newEdge2)
                
                //update next/prev pointers
                nextVertex.incidentEdges[0].twin?.setNext(newEdge2)
                if vertex.incidentEdges.count > 0 {
                    //incident could be inward edge OR previous newEdge2
                    newEdge2.setNext(vertex.incidentEdges[0])
                }
                if let last = lastEdge {
                    last.setNext(newEdge1)
                }
                
                vertex.incidentEdges.append(newEdge1)
                nextVertex.incidentEdges.append(newEdge2)
                
                lastEdge = newEdge1
            }
            
            //looped back to begining
            if nextVertex == borderVertices[0] {
                if let finalEdge1 = lastEdge {
                    for incidentEdge in nextVertex.incidentEdges {
                        if incidentEdge.prev == nil {
                            finalEdge1.setNext(incidentEdge)
                        }
                    }                    
                }
            }
        }
        
        //remove all vertices outside of the bounds
        updatedVertices.append(contentsOf: borderVertices)
        updatedVertices = updatedVertices.filter { contains($0) } //pointers from edges should have already been removed
        
        return (edges: updatedEdges, vertices: updatedVertices)
    }
    
    /**
     Finds the start and end of the edge bounded by the border of this rect.
     - Assumes if origin exists, it lies outside of the bounds.
     - Outputs end as nil if it hasn't changed.
     - Returns nil if the edge has neither breakpoint nor origin, or if the edge has no destination.
     */
    private func boundEdge(_ edge: HalfEdge) -> (start: Coordinate, end: Coordinate?)? {
        
        var startPoint: Coordinate?
        if let breakpoint = edge.breakpoint { //breakpoint case
            let superSweepLine = 2 * (y + height) //extend a sweepline to 2x distance to find the breakpoint
            startPoint = breakpoint.data.calcBreakpoint(sweepLine: superSweepLine)
        }else if let origin = edge.origin { //origin out of bounds condition
            startPoint = origin.coordinate
        }
        
        //get the intersection point of the border and the edge
        //note: doesn't matter if endpoints are both outside bounds, edge could still be partially in bounds.
        if let start = startPoint, let end = edge.destination?.coordinate {
            return getRaycastPoints(start: start, end: end)
        }
        return nil
    }
    
    /**
     Gets the new coordinates of an edge, bounded by the border of this rect.
     - If the end coordinate is within bounds, only update the start point to be along the border
     - If the end coordinate is outside of bounds, also update the end point to be along the border
     - Parameter start: The beginning of the ray, assumed to be a breakpoint or a vertex outside of bounds.
     - Parameter end: The end of the ray, assumed to be a vertex within OR outside of bounds
     - Returns: A new set of start and end coordinates bounded by this rect. nil if no such coordinates can be found.
     */
    private func getRaycastPoints(start: Coordinate, end: Coordinate) -> (start: Coordinate, end: Coordinate?)? {
        
        if contains(end) { //if the end is inside, end->start ray will always pass through one border.
            for segment in borderSegments {
                if let newStart = VectorGeometry.lineRayIntersection(rayEnd: start, rayOrigin: end, p1: segment.0.coordinate, p2: segment.1.coordinate) {
                    return (start: newStart, end: nil)
                }
            }
            return nil
            
        }else { //if end is outside, end->start ray will always pass through zero or two borders.
            
            //we cast the ray from end->start and start->end, thus checking whether the two borders are between or one one side of the ray "points"
            //we ignore the edges that are not in between the start and end points.
            var borderPointsForward: [Coordinate] = []
            let borderPointsBackward: [Coordinate] = []

            for segment in borderSegments {
                if let forwardPoints = VectorGeometry.lineRayIntersection(rayEnd: start, rayOrigin: end, p1: segment.0.coordinate, p2: segment.1.coordinate) {
                    borderPointsForward.append(forwardPoints)
                }
                if let backwardPoints = VectorGeometry.lineRayIntersection(rayEnd: end, rayOrigin: start, p1: segment.0.coordinate, p2: segment.1.coordinate) {
                    borderPointsForward.append(backwardPoints)
                }
            }
            
            if borderPointsForward.count == 2 && borderPointsBackward.count == 2 {
                borderPointsForward.sort { start.distance(to: $0) < start.distance(to: $1) }
                return (start: borderPointsForward[0], end: borderPointsForward[1])
            }
            return nil
        }
    }
    
    
    //MARK: - Deletion
    
    /** Deletes an edge by updating its prev and next's pointers. */
    private func deleteEdge(_ edge: HalfEdge) {
        let prev = edge.prev
        let next = edge.next
        
        if let p = prev, let n = next {
            p.setNext(n)
            n.twin?.setNext(p)
        }
        if let origin = edge.origin, let index = origin.incidentEdges.firstIndex(of: edge) {
            origin.incidentEdges.remove(at: index)
        }
    }
}

private extension Coordinate {
    func distance(to coordinate: Coordinate) {
        sqrt(((coordinate.x - x) ** 2) + ((coordinate.y - y) ** 2))
    }
}
