
Event = require "../src/Event"

describe "Event", ->

  describe ".call()", ->

    it "returns a Listener", ->
      event = Event()
      listener = event emptyFunction
      expect(getType listener).toBe Event.Listener

    it "lazily converts to array storage", ->
      event = Event()
      listener = event emptyFunction
      expect(getType event._listeners).toBe Event.Listener
      listener = event emptyFunction
      expect(getType event._listeners).toBe Array

  describe ".once()", ->

    it "only calls the Listener once", ->
      event = Event()
      listener = event.once emptyFunction
      event.emit()
      event.emit()
      expect(listener.calls).toBe 1

  describe ".many()", ->

    it "calls the Listener the correct number of times", ->
      event = Event()
      listener = event.many 2, emptyFunction
      event.emit()
      event.emit()
      event.emit()
      expect(listener.calls).toBe 2

  describe ".emit()", ->

    it "notifies every attached Listener", ->
      spy = jasmine.createSpy()
      event = Event()
      event spy
      event spy
      event.emit()
      expect(spy.calls.count()).toBe 2

    it "works with just one Listener", ->
      event = Event()
      listener = event emptyFunction
      event.emit()
      expect(listener.calls).toBe 1

    it "works with no listeners", ->
      event = Event()
      expect -> event.emit()
      .not.toThrow()

    it "detaches finished Listeners", ->
      event = Event()
      foo = event.many 2, emptyFunction
      bar = event.once emptyFunction
      expect(event._listeners.length).toBe 2
      event.emit()
      expect(event._listeners).toBe foo
      event.emit()
      expect(event._listeners).toBe null

    it "is bound to the Event", ->
      event = Event()
      listener = event emptyFunction
      emit = event.emit
      emit()
      expect(listener.calls).toBe 1

    bench ->

      event = Event()

      for i in [ 0 .. 5 ]
        event emptyFunction

      @add ".emit()", ->
        event.emit()
