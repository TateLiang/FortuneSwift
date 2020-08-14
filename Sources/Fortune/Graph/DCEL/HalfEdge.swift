//
//  Edge.swift
//  Voronoi
//
//  Created by Tate on 2020-07-09.
//  Copyright © 2020 Tate Liang. All rights reserved.
//

import Foundation

/**
 Defines a HalfEdge of a DCEL.
 - NOTE: This DCEL traverses each face clockwise, with each edge's incident point on the right (assuming y increases downward).
 */
public class HalfEdge: Equatable {
    
    weak var origin: Vertex?
    var destination: Vertex? {
        get { twin?.origin }
        set { twin?.origin = newValue }
    }
    var breakpoint: BeachNode?
    
    private(set) weak var twin: HalfEdge?
    private(set) weak var next: HalfEdge?
    private(set) weak var prev: HalfEdge?
    
    //the point that the edge is tracing out clockwise
    private(set) var incidentSite: Site?
    
    
    
    //MARK: - Setup
    
    init(breakpoint: BeachNode? = nil, incidentSite: Site? = nil, twin: HalfEdge? = nil) {
        self.breakpoint = breakpoint
        
        if let i = incidentSite {
            setIncidentSite(i)
        }
        if let t = twin {
            setTwin(t)
        }
    }
    init(origin: Vertex? = nil, incidentSite: Site? = nil, twin: HalfEdge? = nil) {
        self.origin = origin
        
        if let i = incidentSite {
            setIncidentSite(i)
        }
        if let t = twin {
            setTwin(t)
        }
    }
    
    func setNext(_ edge: HalfEdge) {
        next = edge
        edge.prev = self
    }
    func setTwin(_ edge: HalfEdge) {
        self.twin = edge
        edge.twin = self
    }
    func setIncidentSite(_ site: Site) {
        incidentSite = site
        
        if incidentSite?.firstEdge == nil {
            incidentSite?.firstEdge = self
        }
    }
    
    
    
    //MARK: - Traversal
    
    /**
     Traverses next pointers until it loops back to itself.
     - Returns: An array of the edges in a ring, nil if the edges do not form a ring.
     */
    func walk() -> [HalfEdge]? {
        
        var ring: [HalfEdge] = []
        var currentEdge: HalfEdge = self
        while currentEdge != self {
            ring.append(currentEdge)
            
            guard let next = currentEdge.next else { return nil }
            currentEdge = next
        }
        return ring
    }
    
    
    
    //MARK: - Equatable
    
    public static func == (lhs: HalfEdge, rhs: HalfEdge) -> Bool {
        lhs === rhs
    }
}



//MARK: - Debug

extension HalfEdge: CustomStringConvertible {
    public var description: String {
        var string = ""
        if origin != nil {
             string += "o: \(origin!.description), "
        }else if breakpoint != nil {
            string += "b: \(breakpoint!.description), "
        }else {
            string += "o: nil, "
        }
        string += destination != nil ? "d: \(destination!.description)" : "d: nil"
        
        return string
    }
}
