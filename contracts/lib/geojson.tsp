// GeoJSON geometry primitives (RFC 7946).
//
// Phenomena Atlas is a geospatial API, so these shapes recur across the contract.
// TypeSpec has no official GeoJSON library, so they are modelled once here and reused
// rather than repeated at every endpoint.
//
// Coordinate order is longitude, latitude, in that order, per RFC 7946. This trips
// everyone up at least once: it is the opposite of how coordinates are usually spoken.
//
// WHY Position IS AN ALIAS AND NOT A MODEL
// Declaring it as `model Position is float64[]` hits a known defect in the openapi3
// emitter: a named array model referenced at more than one nesting depth is emitted
// twice, once correctly and once with an "Item" suffix. Verified on @typespec/openapi3
// 1.17.0, the latest release as of 2026-10-22. A fix is merged upstream but unreleased.
// An alias inlines cleanly and produces a correct document. When the fix ships, turn
// this back into a model so the position gains its own named schema and can carry its
// length constraint at every nesting depth instead of only where it is spelled out.

namespace PhenomenaAtlas.GeoJson;

// A coordinate: longitude, latitude, and optional altitude in metres. 2 or 3 numbers.
alias Position = float64[];

@doc("A bounding box: south-west corner followed by north-east corner.")
@minItems(4)
@maxItems(4)
model BoundingBox is float64[];

@doc("A single location.")
model Point {
  type: "Point";

  @minItems(2)
  @maxItems(3)
  coordinates: Position;
}

@doc("A connected sequence of positions.")
model LineString {
  type: "LineString";

  @minItems(2)
  coordinates: Position[];
}

@doc("An area. The first ring is the outer boundary; any further rings are holes.")
model Polygon {
  type: "Polygon";

  @minItems(1)
  coordinates: Position[][];
}

@doc("Several separate locations treated as one geometry.")
model MultiPoint {
  type: "MultiPoint";
  coordinates: Position[];
}

@doc("Several separate areas treated as one geometry.")
model MultiPolygon {
  type: "MultiPolygon";
  coordinates: Position[][][];
}

@doc("Any GeoJSON geometry.")
union Geometry {
  Point,
  LineString,
  Polygon,
  MultiPoint,
  MultiPolygon,
}

@doc("A geometry with domain data attached to it.")
model Feature<TProperties> {
  type: "Feature";
  geometry: Geometry;
  properties: TProperties;

  @doc("Extent of the geometry. Optional, and only an optimisation for clients.")
  bbox?: BoundingBox;
}
