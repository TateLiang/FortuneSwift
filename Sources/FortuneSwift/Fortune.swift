//
//  Fortune.swift
//  Voronoi
//
//  Created by Tate on 2020-07-09.
//  Copyright © 2020 Tate Liang. All rights reserved.
//

import Foundation

/**
 The struct for executing Fortune's Algorithm.
 Performance: O(n log n)
 */
struct Fortune {
    
    //defining the beachLine & sweepLine
    private var beachLine: BeachNode?
    private var eventQueue = PriorityQueue<Event>(sort: <)
    
    //result structures
    private var vertices: [Vertex] = []
    private var edges: [HalfEdge] = []
    private var sites: [Site] = []
    
    /**
     Creates a voronoi diagram from the given sites.
     - Parameter sites: The sites to generate the diagram from.
     - Parameter boundingRect: The area to draw the diagram in.
     */
    mutating func calcVoronoi(from sites: [Coordinate], boundingRect: BoundingRect? = nil) ->
        (sites: [Site], vertices: [Vertex], edges: [HalfEdge]) {
            
        eventQueue = PriorityQueue<Event>(array: Event.array(sites: sites), sort: <)
        
        //traversing the event queue
        while !eventQueue.isEmpty {
            guard let event = eventQueue.dequeue() else { return ([],[],[]) }
            
            switch event {
            case .site(let coordinate):
                handleSiteEvent(at: coordinate)
            case .circle(let coordinate, let center, let parabola):
                handleCircleEvent(at: coordinate, center: center, parabola: parabola)
            }
        }
        
        //cutting off infinite edges
        if let rect = boundingRect {
            let updatedValues = rect.boundEdges(edges: edges, vertices: vertices)
            edges = updatedValues.edges
            vertices = updatedValues.vertices
        }
        
        return (self.sites, vertices, edges)
    }
    
    
    //MARK: - Site Event
    
    /**
     Handles a site event at the specified coordinate.
     - Parameter site: The coordinate of the site.
     - Performance: O(log n) average
     */
    private mutating func handleSiteEvent(at site: Coordinate) {
        if let currentBeachLine = beachLine {
            //finding the parabola at the coordinate's x position
            guard let parabolaAboveSite = currentBeachLine.findParabola(above: site) else { return }
            guard let focus = parabolaAboveSite.data.parabolaSite else { return }
            
            //removes potential false alarm by setting circleEvent = nil
            if parabolaAboveSite.data.parabolaCircleEvent != nil {
                eventQueue.remove(node: parabolaAboveSite.data.parabolaCircleEvent!)
                parabolaAboveSite.data.parabolaCircleEvent = nil
            }
            
            //replace the leaf with a subtree with three leaves
            /*
                   <LBP: OP, NP>
                    /         \
                 <LL: OP>    <RBP: NP, OP>
                                /    \
                          <ML: NP>   <RL: OP>
             */
            let newPoint = site
            let oldPoint = focus
            
            var leftBreakpoint: BeachNode = BeachNode(.breakpoint(sites: (oldPoint, newPoint), edge: nil))
            let rightBreakpoint: BeachNode = BeachNode(.breakpoint(sites: (newPoint, oldPoint), edge: nil))
            
            let leftLeaf: BeachNode = BeachNode(.parabola(site: oldPoint, circleEvent: nil))
            let middleLeaf: BeachNode = BeachNode(.parabola(site: newPoint, circleEvent: nil))
            let rightLeaf: BeachNode = BeachNode(.parabola(site: oldPoint, circleEvent: nil))
            
            rightBreakpoint.adopt(leftChild: middleLeaf, rightChild: rightLeaf)
            leftBreakpoint.adopt(leftChild: leftLeaf, rightChild: rightBreakpoint)
            
            //create half-edges
            let newSite = Site(newPoint)
            let oldSite = Site(oldPoint)
            let leftEdge = HalfEdge(breakpoint: leftBreakpoint, incidentSite: newSite)
            let rightEdge = HalfEdge(breakpoint: rightBreakpoint, incidentSite: oldSite, twin: leftEdge)
            
            edges.append(leftEdge)
            edges.append(rightEdge)
            sites.append(newSite)
            sites.append(oldSite)
            
            leftBreakpoint.data.breakpointEdge = leftEdge
            rightBreakpoint.data.breakpointEdge = rightEdge
            
            //check if breakpoints will converge with parabolas to the left or right
            //(BCD will never converge as B and D are from the same parabola)
            /*
                   <LBP: OP, NP>
              \      /         \
               A ?? B     <RBP: NP, OP>
                             /    \      /
                            C      D ?? E
             */
            
            //replace node with new node
            parabolaAboveSite.replace(with: &leftBreakpoint)
            
            if let leftCousin = leftLeaf.predecessor() {
                checkCircleEvent(leftCousin, leftLeaf, middleLeaf)
            }
            if let rightCousin = rightLeaf.successor() {
                 checkCircleEvent(middleLeaf, rightLeaf, rightCousin)
            }
            
        }else { //if the beachLine is empty, create a new node
            beachLine = BeachNode(.parabola(site: site, circleEvent: nil))
        }
    }
    
    
    //MARK: - Circle Event
    /**
     Handles a circle event at the specified coordinate.
     - Parameter coordinate: The coordinate of the circle event.
     - Parameter center: The center of the circle, where the voronoi vertex is located.
     - Parameter parabola: The parabola that is disappearing.
     - Performance: O(log n) average.
     */
    private mutating func handleCircleEvent(at coordinate: Coordinate, center: Coordinate, parabola: BeachNode) {
        guard let predecessor = parabola.predecessor() else { return }
        guard let successor = parabola.successor() else { return }
        
        //update breakpoints (ie delete parabola in the process)
        guard let updates = deleteParabola(parabola, pred: predecessor, succ: successor, sweepLine: coordinate.y) else { return }
        
        //delete all circle events containing this parabola (ie the 2 neighbours' events)
        if predecessor.data.parabolaCircleEvent != nil {
            eventQueue.remove(node: predecessor.data.parabolaCircleEvent!)
            predecessor.data.parabolaCircleEvent = nil
        }
        if successor.data.parabolaCircleEvent != nil {
            eventQueue.remove(node: successor.data.parabolaCircleEvent!)
            successor.data.parabolaCircleEvent = nil
        }
        
        //create half-edge records
        let vertex = Vertex(center)
        vertices.append(vertex)
        /*
               \  *  /
               A\   /B
                 \ /
                  x
             *L   |C  *R
                 /\
            
            A=updated/left, B=deleted/right, C=newEdge, x=vertex, *L=leftPoint, *R=rightPoint
            A,B⬆ <- origin: vertex
            A,B⬇ <- do nothing
            C⬆ <- newEdge1
            C⬇ <- newEdge2
         */
        if let deleted = updates.deleted,
            let updated = updates.updated,
            let left = updates.left,
            let right = updates.right {
            
            guard let deletedBreakpointEdge = deleted.data.breakpointEdge else { return }
            guard let updatedBreakpointEdge = updated.data.breakpointEdge else { return }
            guard let leftBreakpointEdge = left.data.breakpointEdge else { return }
            guard let rightBreakpointEdge = right.data.breakpointEdge else { return }
            
            //finalizing the old edges' origins
            deletedBreakpointEdge.breakpoint = nil
            deletedBreakpointEdge.origin = vertex
            updatedBreakpointEdge.breakpoint = nil
            updatedBreakpointEdge.origin = vertex

            //creating a new edge
            let leftPoint = updated.data.breakpointSites!.0
            let rightPoint = updated.data.breakpointSites!.1
            let leftSite = Site(leftPoint)
            let rightSite = Site(rightPoint)
            let newEdge1 = HalfEdge(breakpoint: updated, incidentSite: rightSite)
            let newEdge2 = HalfEdge(origin: vertex, incidentSite: leftSite, twin: newEdge1)
            
            edges.append(newEdge1)
            edges.append(newEdge2)
            sites.append(leftSite)
            sites.append(rightSite)

            //setting next pointers (next automatically sets prev)
            //note: we don't set the "twin" of these 3 because they point out of the 3-way intersection
            leftBreakpointEdge.twin?.setNext(newEdge2)
            rightBreakpointEdge.twin?.setNext(leftBreakpointEdge)
            newEdge1.setNext(rightBreakpointEdge)
            
            //adding incidentedges
            vertex.incidentEdges.append(updatedBreakpointEdge)
            vertex.incidentEdges.append(deletedBreakpointEdge)
            vertex.incidentEdges.append(newEdge2)
            
            //update new breakpoint Edge
            updated.data.breakpointEdge = newEdge1
        }

        //Check if any breakpoints converge to add to event queue
        if let superPredecessor = predecessor.predecessor() {
            checkCircleEvent(superPredecessor, predecessor, successor)
        }
        if let superSuccessor = successor.successor() {
            checkCircleEvent(predecessor, successor, superSuccessor)
        }
    }
    
    /**
     Handles the deletion of a parabola and the subsequent updates to nodes.
     - The two breakpoints for this parabola on the left and right are returned as outputs
     
     - Parameter parabola: The parabola to delete.
     - Parameter pred: The predecessor of this parabola.
     - Parameter succ: The successor of this parabola.
     - Parameter sweepLine: The current location of the sweepLine
     - Returns: The two breakpoints classified into deleted, updated, left and right.
     */
    private func deleteParabola(_ parabola: BeachNode, pred: BeachNode, succ: BeachNode, sweepLine: Double) ->
        (deleted: BeachNode?, updated: BeachNode?, left: BeachNode?, right: BeachNode?)? {
        
        var deleted: BeachNode?
        var updated: BeachNode?
        var left: BeachNode?
        var right: BeachNode?
        
        // parabola is left child case:
        /*
              <LBP: PRED, P>
               :          :
            PRED      <RBP: P, SUCC>
                       /      :
                      P      SUCC
         --------------------------------
              <LBP: PRED, SUCC>
               :            :
             PRED          SUCC
        */
        if parabola.isLeftChild() { //implies parent = the breakpoint on the right
            guard var rightParabola = parabola.parent?.rightChild else { return nil }
            parabola.parent?.replace(with: &rightParabola)
            
            //finding the other breakpoint
            guard let leftBreakpoint = beachLine?.getBreakpointNode(between: (pred, parabola), sweepLine: sweepLine) else { return nil }
            guard let successorSite = succ.data.parabolaSite else { return nil }
            leftBreakpoint.data.updateBreakpointSites(right: successorSite)
            
            //assigning to the return variables
            deleted = parabola.parent
            updated = leftBreakpoint
            left = leftBreakpoint
            right = parabola.parent
                
        }else if parabola.isRightChild() { //implies parent = breakpoint on the left
            guard var leftParabola = parabola.parent?.leftChild else { return nil }
            parabola.parent?.replace(with: &leftParabola)
            
            //finding the other breakpoint
            guard let rightBreakpoint = beachLine?.getBreakpointNode(between: (parabola, succ), sweepLine: sweepLine) else { return nil }
            guard let predecessorSite = pred.data.parabolaSite else { return nil }
            rightBreakpoint.data.updateBreakpointSites(left: predecessorSite)
            
            //assigning to the return variables
            deleted = parabola.parent
            updated = rightBreakpoint
            left = parabola.parent
            right = rightBreakpoint
        }
        
        return (deleted: deleted, updated: updated, left: left, right: right)
    }
    
    
    //MARK: - Check Circle Event
    /**
     Checks whether there is a circle event between the three specified nodes,
     adds it to the event queue,
     adds a pointer from the disappearing parabola to it.
     */
    private mutating func checkCircleEvent(_ aNode: BeachNode, _ bNode: BeachNode, _ cNode: BeachNode) {
        guard let a = aNode.data.parabolaSite else { return }
        guard let b = bNode.data.parabolaSite else { return }
        guard let c = cNode.data.parabolaSite else { return }
        
        if let circle = CircleGeometry.make(a, b, c) {
            
            //check counterclockwise since we are using a plane where y increases downward (clockwise if not)
            //^^^ therefore this reverses with the angle calculation which uses unit circle
            if !CircleGeometry.checkClockwise(a, b, c, center: circle.center) {
                let circleEvent: Event = .circle(circle.eventPoint, center: circle.center, parabola: bNode)
                bNode.data.parabolaCircleEvent = circleEvent
                eventQueue.enqueue(circleEvent)
            }
        }
    }
    
}
