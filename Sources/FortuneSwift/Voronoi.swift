//
//  VoronoiBrain.swift
//  Voronoi
//
//  Created by Tate on 2020-07-09.
//  Copyright © 2020 Tate Liang. All rights reserved.
//

import Foundation

/** The model for computing a voronoi diagram. */
public struct Voronoi {
    
    var fortune = Fortune()
    
    public var sites: [Coordinate] = []
    public var voronoiVertices: [Vertex]?
    public var voronoiEdges: [HalfEdge]?
    public var voronoiSites: [Site]?
    
    public init(sites: [Coordinate]? = nil, numPoints: Int, rect: (x: Double, y: Double, width: Double, height: Double)) {
        
        self.sites = sites ?? generateRandomSites(num: numPoints, rect: rect)
        let boundingRect = BoundingRect(x: rect.x, y: rect.y, width: rect.width, height: rect.height)
        
        let output = fortune.calcVoronoi(from: self.sites, boundingRect: boundingRect)
        voronoiVertices = output.vertices
        voronoiEdges = output.edges
        voronoiSites = output.sites
        
    }
    
    
    //MARK: - Generate Random Sites
    /**
     Generates a random number of points within the specified rect.
     - Parameter num: The number of points to generate.
     - Parameter rect: The specified rect.
     */
    private func generateRandomSites(num: Int, rect: (x: Double, y: Double, width: Double, height: Double)) -> [Coordinate] {
        guard num >= 1 else { return [] }

        var generatedSites: [Coordinate] = []
        for _ in 1...num {
            generatedSites.append(Coordinate(x: Double.random(in: rect.x...(rect.x + rect.width)),
                                             y: Double.random(in: rect.y...(rect.y + rect.height))))
        }
        return generatedSites
    }
    
    
    
    //MARK: - Debug
    
    private func printVertices() {
        voronoiVertices?.forEach { vertex in
            print("---\(vertex)---")
            vertex.incidentEdges.forEach { edge in
                print("EDGE: \(edge)")
                print("NEXT: \(String(describing: edge.next))")
                print("PREV: \(String(describing: edge.prev))")
                print("INCIDENT: \(String(describing: edge.incidentSite))")
                print()
            }
            print("-----------")
            print()
        }
    }
}
