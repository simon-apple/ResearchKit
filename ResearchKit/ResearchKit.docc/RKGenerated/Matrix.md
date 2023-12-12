# ``/ResearchKit/Matrix``

<!-- The content below this line is auto-generated and is redundant. You should either incorporate it into your content above this line or delete it. -->

## Topics

### Structures

- ``MutableSlice``
- ``Shape``
- ``Slice``

### Operators

- ``*(_:_:)-39uqw`` <!-- static func * (lhs: `Self`, rhs: `Self`) -> Matrix<Element> -->
- ``*(_:_:)-4vgm7`` <!-- static func * (lhs: `Self`, rhs: `Self`) -> Matrix<Element> -->
- ``+(_:_:)-1c590`` <!-- static func + (lhs: Matrix<Element>, rhs: Vector<Element>) -> Matrix<Element> -->

### Initializers

- ``init(elements:rows:columns:)``
- ``init(elements:shape:)``
- ``init(repeating:rows:columns:)``
- ``init(repeating:shape:)``
- ``init(rows:)``

### Instance Properties

- ``elements``
- ``rows``
- ``shape``

### Instance Methods

- ``aggregate1(along:aggregation:)``
- ``aggregate2(along:transform:)``
- ``appendRow(_:)``
- ``appendRows(of:)``
- ``appendingColumn(_:)``
- ``appendingColumns(of:)``
- ``det()``
- ``divide(by:along:)-652j``                             <!-- mutating func divide(by vector: Vector<Double>, along axis: Axis) -->
- ``divide(by:along:)-7pigs``                            <!-- mutating func divide(by vector: Vector<Float>, along axis: Axis) -->
- ``getColumn(_:)``
- ``getRow(_:)``
- ``index(position:)``
- ``inv()``
- ``magnitude(along:)-1zreh``                            <!-- func magnitude(along axis: Axis) -> Vector<Double> -->
- ``magnitude(along:)-6ftee``                            <!-- func magnitude(along axis: Axis) -> Vector<Float> -->
- ``mean(along:)-6qhzt``                                 <!-- func mean(along axis: Axis) -> Vector<Element> -->
- ``mean(along:)-i6hf``                                  <!-- func mean(along axis: Axis) -> Vector<Element> -->
- ``meanAndStandardDeviation(along:)``
- ``modify(along:transform:)-4lliw``                     <!-- mutating func modify(along axis: Axis, transform: (MutableSlice) -> Void) -->
- ``modify(along:transform:)-8fe18``                     <!-- mutating func modify<Value0, Value1>(along axis: Axis, transform: (MutableSlice, UnsafeMutablePointer<Value0>, UnsafeMutablePointer<Value1>) -> Void) -> (Vector<Value0>, Vector<Value1>) where Value0 : FloatingPoint, Value1 : FloatingPoint -->
- ``multipliedByTransposed()``
- ``normalizeAndReturnMeanAndStandardDeviation(along:)``
- ``normalizeMagnitude(along:)``
- ``normalizeMeanAndStandardDeviation(along:)``
- ``number(of:)``
- ``position(row:column:)``
- ``pow(expoent:)``
- ``slogdet()``
- ``sum(along:)-43m5a``                                  <!-- func sum(along axis: Axis) -> Vector<Element> -->
- ``sum(along:)-6eh7o``                                  <!-- func sum(along axis: Axis) -> Vector<Element> -->
- ``transposed()-21uf3``                                 <!-- func transposed() -> Matrix<Element> -->
- ``transposed()-9v398``                                 <!-- func transposed() -> Matrix<Element> -->

### Subscripts

- ``subscript(_:_:)``
- ``subscript(columnIndices:)-2cgop`` <!-- subscript(columnIndices columnIndices: [Int]) -> `Self` { get } -->
- ``subscript(columnIndices:)-3lxj9`` <!-- subscript(columnIndices columnIndices: [Int]) -> `Self` { get } -->

### Type Aliases

- ``Axis``

### Type Methods

- ``exp(_:)``
- ``eye(_:)``
- ``log(_:)``
- ``mGrid(xRange:xSteps:yRange:ySteps:)``
- ``ones(rows:columns:)``
- ``reshape2columns(_:)``
- ``stack(_:_:)``
- ``zeros(rows:columns:)``