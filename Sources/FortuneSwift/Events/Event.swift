//
//  Event.swift
//  Voronoi
//
//  Created by Tate on 2020-07-09.
//  Copyright © 2020 Tate Liang. All rights reserved.
//

import Foundation

/**
 An event from the event queue, can a be site or circle event.
 */
enum Event: Comparable, Equatable {
    
    case site(Coordinate)
    case circle(Coordinate, center: Coordinate, parabola: Weak<BeachNode>)
    
    var coordinate: Coordinate {
        switch self {
        case .site(let p): return p
        case .circle(let p, _, _): return p
        }
    }
    
    /**
     Generates an array of site events
     - Parameter sites: An array of sites.
     */
    static func array(sites: [Coordinate]) -> [Event] {
        var eventArray: [Event] = []
        sites.forEach { eventArray.append(.site($0)) }
        return eventArray
    }
    
    
    
    //MARK: - Conformity
    
    static func < (lhs: Event, rhs: Event) -> Bool {
        lhs.coordinate < rhs.coordinate
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.coordinate == rhs.coordinate
    }
    
}



