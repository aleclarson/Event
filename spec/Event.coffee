
getType = require "getType"

Event = require "../src/Event"

describe "event(callback)", ->

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

describe "event.once(callback)", ->

  it "only calls the Listener once", ->
    event = Event()
    listener = event.once emptyFunction
    event.emit()
    event.emit()
    expect(listener.calls).toBe 1

describe "event.many(limit, callback)", ->

  it "calls the Listener the correct number of times", ->
    event = Event()
    listener = event.many 2, emptyFunction
    event.emit()
    event.emit()
    event.emit()
    expect(listener.calls).toBe 2

describe "event.emit(args...)", ->

  it "notifies every attached Listener", ->
    spy = jasmine.createSpy()
    event = Event()
    event spy
    event spy
    event.emit()
    expect(spy.calls.count()).toBe 2

  it "works with just one Listener", ->
    event = Event()
    listener = event.many 2, emptyFunction
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
    listener = event.many 2, emptyFunction
    emit = event.emit
    emit()
    expect(listener.calls).toBe 1

  it "can defuse a listener during an emit", ->

    spy = jasmine.createSpy()

    event = Event()

    foo = event ->
      spy 0
      bar.defuse()

    bar = event ->
      spy 1

    zen = event ->
      spy 2

    event.emit()

    expect spy.calls.count()
      .toBe 2

    expect spy.calls.argsFor 0
      .toContain 0

    expect spy.calls.argsFor 1
      .toContain 2

  it "detaches a listener that defuses itself", ->

    event = Event()

    foo = event ->

      foo.defuse()

      # Wait until the emit finishes before detaching dead listeners.
      expect event.listenerCount
        .toBe 1

    event.emit()

    expect event.listenerCount
      .toBe 0

  it "detaches a listener that is defused by an earlier listener", ->

    event = Event()

    foo = event ->

      bar.defuse()

      # Wait until the emit finishes before detaching dead listeners.
      expect event.listenerCount
        .toBe 2

    # This should never be called.
    bar = event spy = jasmine.createSpy()

    event.emit()

    expect event.listenerCount
      .toBe 1

    expect spy.calls.count()
      .toBe 0

  it "detaches a listener that is defused by a later listener", ->

    event = Event()

    foo = event emptyFunction

    bar = event ->

      foo.defuse()

      # Wait until the emit finishes before detaching dead listeners.
      expect event.listenerCount
        .toBe 2

    event.emit()

    expect event.listenerCount
      .toBe 1

  bench ->

    event = Event()

    for i in [ 0 .. 5 ]
      event emptyFunction

    @add ".emit()", ->
      event.emit()
