# FortuneSwift

FortuneSwift is a swift framework that uses Fortune's Algorithm to generate Voronoi diagrams and Delaunay triangulations from a set of points on a 2D plane. Fortune's Algorithm has a time complexity of `O(n log n)`, and a space complexity of `O(n)`. This framework is compatible with iOS 8+, macOS 10.13+.

## Examples
<p align="left">
  <img src="https://github.com/TateLiang/FortuneSwift/blob/TateLiang-description-edit/Images/voronoi_img1.jpg" width="400">
  <img src="https://github.com/TateLiang/FortuneSwift/blob/TateLiang-description-edit/Images/voronoi_img2.jpg" width="400">
  <img src="https://github.com/TateLiang/FortuneSwift/blob/TateLiang-description-edit/Images/voronoi_img3.jpg" width="400">
  <img src="https://github.com/TateLiang/FortuneSwift/blob/TateLiang-description-edit/Images/voronoi_img4.jpg" width="400">
</p>


## Installation

The FortuneSwift framework can be installed using the Swift Package Manager. In Xcode: `File > Swift Packages > Add Package Dependency..` with URL: `https://github.com/TateLiang/FortuneSwift.git`

Or alternatively:
- Add `.package(url: "https://github.com/TateLiang/FortuneSwift.git", from: "1.1.6")` to your `Package.swift` file's `dependencies`.
- Update your packages using `$ swift package update`.

## Usage

### Setup

1. Add package dependancy
2. Import `import FortuneSwift`
3. Create a `Voronoi` object, specifying an array of `Coordinate`s and the rectangular area.
```
let points: [Coordinate] = [ ... ]
let rect = (x: 25, y: 25, width: 500, height: 500)

let voronoi = Voronoi(sites: points, numPoints: points.count, rect: rect)
```

Alternatively, if the array is not given, `numPoints` of random points are generated within the rectangular area.
```
let voronoi = Voronoi(numPoints: 150, rect: rect)
```

### Processing Graph

FortuneSwift outputs a doubly connected edge list (DCEL) stored as arrays of sites, voronoi vertices and half-edges. This framework provides four classes for accessing the diagram: `Coordinate`, `Site`, `Vertex` and `HalfEdge`. This information can be used to draw a Voronoi diagram or Delaunay triangulation.

Once the voronoi object has been created, the resulting arrays can be obtained via the properties:
```
var voronoiVertices: [Vertex]
var voronoiEdges: [HalfEdge]
var voronoiSites: [Site]
```

The main properties of each class are detailed below. 

##### Site
```
var x: Double
var y: Double
var firstEdge: HalfEdge?
var surroundingEdges: [HalfEdge]?
```

##### Vertex
```
var x: Double
var y: Double
var incidentEdges: [HalfEdge]
```

##### HalfEdge
```
var origin: Vertex?
var destination: Vertex?

var twin: HalfEdge?
var next: HalfEdge?
var prev: HalfEdge?

var incidentSite: Site?

func walk() -> [HalfEdge]? 
```

### Notes

- `firstEdge` is an arbitrary edge defining the voronoi cell of a site. `surroundingEdges` can be used for a list of all edges defining the cell.
- The `HalfEdge`s trace out a voronoi cell counter-clockwise with the incidentSite to its left, assuming a coordinate system where y increases upward and x increases rightward.
- `incidentSite` is `nil` if it is an edge on the exterior border of the bounding rectangle.
- `walk()` outputs an ring of the `HalfEdges` defining the cell, or `nil` if the edges don't form a ring (should not happen)

## Details

##### Problem Definition
A voronoi diagram is a tesselation of cells in a plane, representing the points closest to a particular point. For each voronoi "site", its region is defined as the points closer to it than any other site. Voronoi diagrams are also dual-graphs of the Delaunay triangulation, where each edge of the Voronoi diagram corresponds to an adjacent edge in the Delaunay triangulation between the two incident points. Voronoi diagrams have a variety of applications including in Astronomy, Art, Biology, Robotics, and Physics.

##### Algorithm
[Fortune's Algorithm](https://en.wikipedia.org/wiki/Fortune%27s_algorithm) is a sweep line algorithm in computational geometry. Like problems such as convex hulls or segment intersection, an event queue is maintained through a priority queue data structure. Fortune's Algorithm makes use of a binary search tree to also maintain a "beach line", representing the currently known cells based on the location of the sweep line. At the end of the algorithm, the infinite edges can be bounded by a polygon, in this case, a rectangle.

## Issues

- Points outside of the bounding box will still effect the voronoi diagram, as the box simply bounds all of the infinite edges.
- The algorithm does not work with the edge case where all points are collinear.
- The algorithm does not work with the edge case where there are multiple sites at the same location.
