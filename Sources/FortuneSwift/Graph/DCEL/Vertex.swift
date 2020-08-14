//
//  Vertex.swift
//  Voronoi
//
//  Created by Tate on 2020-07-09.
//  Copyright © 2020 Tate Liang. All rights reserved.
//

import Foundation

/** Defines a voronoi vertex. */
public class Vertex: Equatable {
    
    public var x: Double
    public var y: Double
    
    //Edges going out from the vertex
    public var incidentEdges: [HalfEdge] = []
    
    public var coordinate: Coordinate {
        Coordinate(x: x, y: y)
    }
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    public init(_ coordinate: Coordinate) {
        self.x = coordinate.x
        self.y = coordinate.y
    }
    
    public static func == (lhs: Vertex, rhs: Vertex) -> Bool {
        lhs === rhs
    }
}


//MARK: - Debug

extension Vertex: CustomStringConvertible {
    public var description: String {
        "\(round(x*10)/10), \(round(y*10)/10)"
    }
}

