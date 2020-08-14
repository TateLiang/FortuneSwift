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
    
    var x: Double
    var y: Double
    
    //Edges going out from the vertex
    var incidentEdges: [HalfEdge] = []
    
    var coordinate: Coordinate {
        Coordinate(x: x, y: y)
    }
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    init(_ coordinate: Coordinate) {
        self.x = coordinate.x
        self.y = coordinate.y
    }
    
    static func == (lhs: Vertex, rhs: Vertex) -> Bool {
        lhs === rhs
    }
}


//MARK: - Debug

extension Vertex: CustomStringConvertible {
    var description: String {
        "\(round(x*10)/10), \(round(y*10)/10)"
    }
}

