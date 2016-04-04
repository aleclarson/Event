
Event = require "../src/Event"

describe "Listener", ->

  describe ".notify()", ->

    it "calls the '_onEvent' property", ->
      event = Event()
      listener = event jasmine.createSpy()
      listener.notify()
      expect(listener._onEvent.calls.count()).toBe 1

    it "increments the 'calls' property", ->
      event = Event()
      listener = event emptyFunction
      listener.notify()
      expect(listener.calls).toBe 1
      listener.notify()
      expect(listener.calls).toBe 2

    it "detaches the Listener if 'maxCalls' is reached", ->
      event = Event()
      listener = event.once emptyFunction
      listener.notify()
      listener.notify()
      expect(listener.calls).toBe 1

  describe ".stop()", ->

    it "detaches the Listener", ->
      event = Event()
      listener = event emptyFunction
      event.emit()
      listener.stop()
      event.emit()
      expect(listener.calls).toBe 1

    it "can be safely called multiple times", ->
      event = Event()
      listener = event emptyFunction
      listener.stop()
      expect -> listener.stop()
      .not.toThrow()
