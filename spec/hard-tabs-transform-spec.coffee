Point = require "../src/point"
HardTabsTransform = require "../src/hard-tabs-transform"
StringLayer = require "../src/string-layer"
TransformLayer = require "../src/transform-layer"

describe "HardTabsTransform", ->
  layer = null

  beforeEach ->
    layer = new TransformLayer(new StringLayer("\tabc\tdefg\t"), new HardTabsTransform(4))

  it "breaks the source text into lines", ->
    iterator = layer[Symbol.iterator]()
    expect(iterator.next()).toEqual(value: "\t   ", done: false)
    expect(iterator.getPosition()).toEqual(Point(0, 4))
    expect(iterator.getSourcePosition()).toEqual(Point(0, 1))

    expect(iterator.next()).toEqual(value: "abc", done: false)
    expect(iterator.getPosition()).toEqual(Point(0, 7))
    expect(iterator.getSourcePosition()).toEqual(Point(0, 4))

    expect(iterator.next()).toEqual(value: "\t", done: false)
    expect(iterator.getPosition()).toEqual(Point(0, 8))
    expect(iterator.getSourcePosition()).toEqual(Point(0, 5))

    expect(iterator.next()).toEqual(value: "defg", done: false)
    expect(iterator.getPosition()).toEqual(Point(0, 12))
    expect(iterator.getSourcePosition()).toEqual(Point(0, 9))

    expect(iterator.next()).toEqual(value: "\t   ", done: false)
    expect(iterator.getPosition()).toEqual(Point(0, 16))
    expect(iterator.getSourcePosition()).toEqual(Point(0, 10))

    expect(iterator.next()).toEqual(done: true)
    expect(iterator.next()).toEqual(done: true)
    expect(iterator.getPosition()).toEqual(Point(0, 16))
    expect(iterator.getSourcePosition()).toEqual(Point(0, 10))