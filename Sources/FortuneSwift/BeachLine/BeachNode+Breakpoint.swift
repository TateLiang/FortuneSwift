//
//  BSTNode+Breakpoint.swift
//  Voronoi
//
//  Created by Tate on 2020-07-09.
//  Copyright © 2020 Tate Liang. All rights reserved.
//

import Foundation

extension BeachNode.Data {
    
    /**
     Calculate the intersection point of this breakpoint.
     - Fails if this node is not a breakpoint.
     - Parameter sweepLine: The current position of the sweepLine
     - Returns: The coordinates of the intersection, or y=nil if the intersection does not exist.
     - Performance: O(1)
     */
    func calcBreakpoint(sweepLine: Double) -> Coordinate? {
        guard let (i, j) = breakpointSites else { return nil }
        
        let l = sweepLine
        var a = i.x
        var b = i.y
        let c = j.x
        let d = j.y
        var u = 2 * (i.y - l)
        
        var output: (x: Double, y: Double) = (x: 0, y: 0)
        
        //Arbitrary parabola to substitute output.x into at end to find output.y
        var p: Coordinate = i
        
        //finding x
        if i.y == j.y {
            output.x = (i.x + j.x)/2
            
            //degenerate case where both on sweepline therefore no intersection
            if i.y == l {
                return nil
            }
        }else if i.y == l {
            output.x = i.x
            p = j //case where i is unusable as it's a vertical line
        }else if j.y == l {
            output.x = j.x
        }else {
            // solve for x: 1/m * ((x - a)^2 + b^2 - l^2) = 1/n * ((x - c)^2 + d^2 - l^2)
            // aka: (1/(2(b-k)))((x-a)^2)+((b+k)/2)=(1/(2(d-k)))((x-c)^2)+((d+k)/2)
            
            /* Wolfram Alpha:
             (c m - a n - Sqrt[
                -(d^2 m^2) + l^2 m^2 + a^2 m n + b^2 m n - 2 a c m n + c^2 m n + d^2 m n - 2 l^2 m n - b^2 n^2 + l^2 n^2
             ])/(m - n) */
            
            output.x = (sqrt((b*d - b*l - d*l + (l**2)) * ((a**2) - 2*a*c + (b**2) - 2*b*d + (c**2) + (d**2))) - a*d + a*l + b*c - c*l)/(b-d)
        }
        
        //finding y
        a = p.x
        b = p.y
        u = 2 * (b - l)
        let x = output.x
        output.y = (1 / u) * (((x - a) ** 2) + (b ** 2) - (l ** 2))
        
        return Coordinate(x: output.x, y: output.y)
    }
}

