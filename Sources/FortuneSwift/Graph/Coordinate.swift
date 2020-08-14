//
//  Point.swift
//  Voronoi
//
//  Created by Tate on 2020-07-09.
//  Copyright © 2020 Tate Liang. All rights reserved.
//

import Foundation

/** Defines a coordinate location in space. */
public struct Coordinate: Comparable, Equatable {
    public var x: Double
    public var y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    public static func < (lhs: Coordinate, rhs: Coordinate) -> Bool {
        lhs.y < rhs.y
    }
}

//MARK: - Debug

extension Coordinate: CustomStringConvertible {
    public var description: String {
        "\(round(x*10)/10), \(round(y*10)/10)"
    }
}
