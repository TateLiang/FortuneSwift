//
//  Math.swift
//  Voronoi
//
//  Created by Tate on 2020-07-09.
//  Copyright © 2020 Tate Liang. All rights reserved.
//

import Foundation

/**
 Power function
 - Parameter num: The base.
 - Parameter power: The exponent.
 */
infix operator **
func ** (num: Double, power: Double) -> Double {
    pow(num, power)
}
