//
//  LineIntersection.swift
//  Voronoi
//
//  Created by Tate on 2020-07-09.
//  Copyright © 2020 Tate Liang. All rights reserved.
//

import Foundation
import simd

struct VectorGeometry {
    
    /** 2D Vector implementation. */
    private struct Vector2 {
        var x: Double
        var y: Double
        
        var magnitude: Double {
            sqrt((x ** 2) + (y ** 2))
        }
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
        
        static func sum(_ v1: Vector2, _ v2: Vector2) -> Vector2 {
            Vector2(x: v1.x + v2.x, y: v1.y + v2.y)
        }
        static func difference(_ v1: Vector2, _ v2: Vector2) -> Vector2 {
            Vector2(x: v1.x - v2.x, y: v1.y - v2.y)
        }
        static func cross(_ v1: Vector2, _ v2: Vector2) -> Double {
            (v1.x * v2.y) - (v1.y * v2.x)
        }
        static func dot(_ v1: Vector2, _ v2: Vector2) -> Double {
            (v1.x * v2.x) + (v1.y * v2.y)
        }
        static func multiply(_ n: Double, _ v: Vector2) -> Vector2 {
            Vector2(x: v.x * n, y: v.y * n)
        }
        static func norm(_ v: Vector2) -> Vector2 {
            let magnitude = v.magnitude
            guard magnitude != 0 else { return v }
            return Vector2(x: v.x / magnitude, y: v.y / magnitude)
        }
    }
    
    /**
     Finds the coordinate of an intersection between a line and a ray.
     - Parameter rayEnd: An arbitrary point along the ray representing its direction.
     - Parameter rayOrigin: The origin point of the ray.
     - Parameter p1: First point of a line segment.
     - Parameter p2: Second point of a line segment.
     - Returns: The coordinate of the intersection, or nil if no intersection.
     */
    static func lineRayIntersection(rayEnd: Coordinate, rayOrigin: Coordinate, p1: Coordinate, p2: Coordinate) -> Coordinate? {
        //p + t*r = q + u*s
        //where p: origin, q: point1
        
        let origin = Vector2(rayOrigin)
        let end = Vector2(rayEnd)
        
        let point1 = Vector2(p1)
        let point2 = Vector2(p2)
        
        let r = Vector2.norm(Vector2.difference(end, origin))
        let s = Vector2.difference(point2, point1)
        
        let t = Vector2.cross(Vector2.difference(point1, origin), s) / Vector2.cross(r, s)
        let u = Vector2.cross(Vector2.difference(origin, point1), r) / Vector2.cross(s, r)
        
        if t > 0 && 0 <= u && u <= 1 {
            return Vector2.sum(origin, Vector2.multiply(t, r)).coordinate
        }
        return nil
    }
}
