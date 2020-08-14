# FortuneSwift

FortuneSwift is a swift framework that uses Fortune's Algorithm to generate Voronoi diagrams and Delaunay triangulations from a set of points on a 2D plane. Fortune's Algorithm has a time complexity of `O(n log n)`, and a space complexity of `O(n)`. This framework is compatible with iOS 8+, macOS 10.13+.


## Installation

The FortuneSwift framework can be installed using the Swift Package Manager. In Xcode: `File > Swift Packages > Add Package Dependency..` with URL: `https://github.com/TateLiang/FortuneSwift.git`

Or alternatively:
- Add `.package(url: "https://github.com/TateLiang/FortuneSwift.git", from: "1.1.5")` to your `Package.swift` file's `dependencies`.
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

## Issues

- Points outside of the bounding box will still effect the voronoi diagram, as the box simply bounds all of the infinite edges.
- The algorithm does not work with the edge case where all points are collinear.
- The algorithm does not work with the edge case where there are multiple sites at the same location.

