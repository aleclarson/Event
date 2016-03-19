
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

    it "returns true if the Listener is still attached", ->
      event = Event()
      listener = event.many 2, emptyFunction
      expect(listener.notify()).toBe yes
      expect(listener.notify()).toBe no

    it "detaches the Listener if 'maxCalls' is reached", ->
      event = Event()
      listener = event.once emptyFunction
      listener.notify()
      listener.notify()
      expect(listener.calls).toBe 1
      expect(listener.notify).toBe emptyFunction
      expect(listener.stop).toBe emptyFunction

  describe ".stop()", ->

    it "detaches the Listener", ->
      event = Event()
      listener = event emptyFunction
      event.emit()
      listener.stop()
      event.emit()
      expect(listener.calls).toBe 1
      expect(listener.notify).toBe emptyFunction
      expect(listener.stop).toBe emptyFunction

    it "can be safely called multiple times", ->
      event = Event()
      listener = event emptyFunction
      listener.stop()
      expect -> listener.stop()
      .not.toThrow()

    it "works inside the Listener", ->
      event = Event()
      foo = event -> foo.stop()
      bar = event emptyFunction
      event.emit()
      event.emit()
      expect(foo.calls).toBe 1
      expect(bar.calls).toBe 2

    it "works inside another Listener", ->
      event = Event()
      foo = event emptyFunction
      bar = event -> foo.stop()
      event.emit()
      event.emit()
      expect(foo.calls).toBe 1
      expect(bar.calls).toBe 2
