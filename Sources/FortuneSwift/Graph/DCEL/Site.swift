//
//  Site.swift
//  Voronoi
//
//  Created by Tate on 2020-07-09.
//  Copyright © 2020 Tate Liang. All rights reserved.
//

import Foundation

/** Defines a site of a voronoi diagram. */
public class Site: Equatable {
    
    public var x: Double
    public var y: Double
    
    //An edge along a border of the cell of this site
    public weak var firstEdge: HalfEdge?
    public var surroundingEdges: [HalfEdge]? {
        firstEdge?.walk()
    }
    
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
    
    public static func == (lhs: Site, rhs: Site) -> Bool {
        lhs === rhs
    }
}


//MARK: - Debug

extension Site: CustomStringConvertible {
    public var description: String {
        "\(round(x*10)/10), \(round(y*10)/10)"
    }
}
