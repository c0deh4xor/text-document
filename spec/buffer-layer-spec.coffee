Point = require "../src/point"
{EOF} = require "../src/symbols"
SpyLayer = require "./spy-layer"
BufferLayer = require "../src/buffer-layer"

describe "BufferLayer", ->
  describe "::slice(start, end)", ->
    it "returns the content between the given start and end positions", ->
      source = new SpyLayer("abcdefghijkl", 3)
      buffer = new BufferLayer(source)

      expect(buffer.slice(Point(0, 1), Point(0, 3))).toBe "bcd"
      expect(source.getRecordedReads()).toEqual ["bcd"]
      source.reset()

      expect(buffer.slice(Point(0, 2), Point(0, 4))).toBe "cdef"
      expect(source.getRecordedReads()).toEqual ["cde", "fgh"]

    it "returns the entire input text when no bounds are given", ->
      source = new SpyLayer("abcdefghijkl", 3)
      buffer = new BufferLayer(source)

      expect(buffer.slice()).toBe "abcdefghijkl"
      expect(source.getRecordedReads()).toEqual ["abc", "def", "ghi", "jkl", EOF]

  describe "iteration", ->
    it "returns an iterator into the buffer", ->
      source = new SpyLayer("abcdefghijkl", 3)
      buffer = new BufferLayer(source)
      iterator = buffer[Symbol.iterator]()
      iterator.seek(Point(0, 3))

      expect(iterator.next()).toEqual(value:"def", done: false)
      expect(iterator.getPosition()).toEqual(Point(0, 6))

      expect(iterator.next()).toEqual(value:"ghi", done: false)
      expect(iterator.getPosition()).toEqual(Point(0, 9))

      expect(iterator.next()).toEqual(value:"jkl", done: false)
      expect(iterator.getPosition()).toEqual(Point(0, 12))

      expect(iterator.next()).toEqual(value: EOF, done: true)
      expect(iterator.getPosition()).toEqual(Point(0, 12))

      expect(source.getRecordedReads()).toEqual ["def", "ghi", "jkl", EOF]
      source.reset()

      iterator.seek(Point(0, 5))
      expect(iterator.next()).toEqual(value:"fgh", done: false)

  describe "::setActiveRegion(start, end)", ->
    it "causes the buffer to cache the text within the given boundaries", ->
      source = new SpyLayer("abcdefghijkl", 3)
      buffer = new BufferLayer(source)

      expect(buffer.slice()).toBe "abcdefghijkl"
      expect(source.getRecordedReads()).toEqual ["abc", "def", "ghi", "jkl", EOF]
      source.reset()

      expect(buffer.slice()).toBe "abcdefghijkl"
      expect(source.getRecordedReads()).toEqual ["abc", "def", "ghi", "jkl", EOF]
      source.reset()

      buffer.setActiveRegion(Point(0, 4), Point(0, 7))

      expect(buffer.slice()).toBe "abcdefghijkl"
      expect(source.getRecordedReads()).toEqual ["abc", "def", "ghi", "jkl", EOF]
      source.reset()

      expect(buffer.slice()).toBe "abcdefghijkl"
      expect(source.getRecordedReads()).toEqual ["abc", "jkl", EOF]
      source.reset()

      expect(buffer.slice(Point(0, 0), Point(0, 6))).toBe "abcdef"
      expect(source.getRecordedReads()).toEqual ["abc"]