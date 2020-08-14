//
//  CircleGeometry.swift
//  Voronoi
//
//  Created by Tate on 2020-07-09.
//  Copyright © 2020 Tate Liang. All rights reserved.
//

import Foundation

struct CircleGeometry {
    
    /**
     Creates a circle from three coordinates.
     - Fails if the points are collinear
     - Returns: The center of the circle and the point on the circle at which the circleEvent occurs
     */
    static func make(_ p1: Coordinate, _ p2: Coordinate, _ p3: Coordinate) -> (center: Coordinate, eventPoint: Coordinate)? {
        let a = p1
        let b = p2
        let c = p3
        
        let A = b.x - a.x
        let B = b.y - a.y
        let C = c.x - a.x
        let D = c.y - a.y
        let E = (A * (a.x + b.x)) + (B * (a.y + b.y))
        let F = (C * (a.x + c.x)) + (D * (a.y + c.y))
        let G = ((A * (c.y - b.y)) - (B * (c.x - b.x))) * 2
        
        // G=0: collinear, G<0: non-converging
        // could change to G < 0 and not need checkClockwise()
        guard G != 0 else { return nil }
        let centerX = ((D * E) - (B * F)) / G
        let centerY = ((A * F) - (C * E)) / G
        let center = Coordinate(x: centerX, y: centerY)
        
        let radius = sqrt(((a.x - centerX) ** 2) + ((a.y - centerY) ** 2))
        let bottomPoint = Coordinate(x: centerX, y: centerY + radius)
        
        return (center: center, eventPoint: bottomPoint)
    }
    
    /** Convert a negative radian angle into a positive one. */
    private static func getPosAngle(_ angle: Double) -> Double {
        var result = angle
        while result < 0 {
            result += Double.pi * 2
        }
        return result
    }
    
    /** Get the radian angle between a point on a circle and the center of the circle. */
    static func getAngle(point: Coordinate, center: Coordinate) -> Double {
        let dx = point.x - center.x
        let dy = point.y - center.y
        var theta = atan2(dy, dx)
        theta = getPosAngle(theta)
        return theta
    }
    
    /** Check whether the specified three points are ordered clockwise around the circle defined by the center */
    static func checkClockwise(_ p1: Coordinate, _ p2: Coordinate, _ p3: Coordinate, center: Coordinate) -> Bool {
        let theta1 = getAngle(point: p1, center: center)
        let theta2 = getAngle(point: p2, center: center)
        let theta3 = getAngle(point: p3, center: center)
        
        return getPosAngle(theta3 - theta2) > getPosAngle(theta3 - theta1)
    }
}


