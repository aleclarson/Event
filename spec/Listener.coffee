
Event = require "../src/Event"

describe "listener.notify()", ->

  it "calls the '_onNotify' property", ->
    event = Event()
    listener = event jasmine.createSpy()
    listener.notify()
    expect(listener._onNotify.calls.count()).toBe 1

  it "increments the 'calls' property", ->
    event = Event()
    listener = event.many 3, emptyFunction
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

describe "listener.defuse()", ->

  it "detaches the Listener from its Event", ->
    event = Event()
    listener = event.many 5, emptyFunction
    event.emit()
    listener.defuse()
    event.emit()
    expect(event.listenerCount).toBe 0
    expect(listener.calls).toBe 1

  it "can be safely called multiple times", ->
    event = Event()
    listener = event emptyFunction
    listener.defuse()
    expect -> listener.defuse()
    .not.toThrow()

describe "listener.stop()", ->

  it "disables the Listener without defusing it", ->
    event = Event()
    listener = event.many 5, emptyFunction
    event.emit()
    listener.stop()
    event.emit()
    expect(event.listenerCount).toBe 1
    expect(listener.calls).toBe 1

  it "can be safely called multiple times", ->
    event = Event()
    listener = event emptyFunction
    listener.stop()
    expect -> listener.stop()
    .not.toThrow()
