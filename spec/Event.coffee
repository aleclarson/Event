
getType = require "getType"

Event = require ".."

# TODO: Special case for calling 'reset' while notifying listeners
# TODO: Special cases for async emitters

# TODO: Special case for calling 'reset' while notifying listeners
# TODO: Special cases for async/sync emitters

describe "event(callback)", ->

  it "returns a Listener", ->

    event = Event {async: no}
    listener = event emptyFunction

    expect getType listener
      .toBe Event.Listener

  it "lazily converts to array storage", ->

    event = Event {async: no}

    foo = event emptyFunction
    foo.start()

    expect event._listeners._value
      .toBe foo

    bar = event emptyFunction
    bar.start()

    expect event._listeners._value
      .toEqual [ foo, bar ]

  it "supports stopping the Listener after one emit", ->

    event = Event {async: no}

    listener = event 1, emptyFunction
    listener.start()

    event.emit()
    event.emit()

    expect listener.calls
      .toBe 1

  it "supports stopping the Listener after X emits", ->

    event = Event {async: no}

    listener = event 2, emptyFunction
    listener.start()

    event.emit()
    event.emit()
    event.emit()

    expect listener.calls
      .toBe 2

describe "event.emit(args...)", ->

  it "notifies every attached Listener", ->

    event = Event {async: no}

    foo = event 1, emptyFunction
    foo.start()

    bar = event 1, emptyFunction
    bar.start()

    event.emit()

    expect foo.calls
      .toBe 1

    expect bar.calls
      .toBe 1

  it "works with just one Listener", ->

    event = Event {async: no}

    listener = event 2, emptyFunction
    listener.start()

    event.emit()

    expect listener.calls
      .toBe 1

  it "works with no listeners", ->

    event = Event {async: no}

    expect -> event.emit()
      .not.toThrow()

  it "detaches finished Listeners", ->

    event = Event {async: no}

    foo = event 2, emptyFunction
    foo.start()

    bar = event 1, emptyFunction
    bar.start()

    expect event.listenerCount
      .toBe 2

    event.emit()

    expect event._listeners._value
      .toBe foo

    event.emit()

    expect event._listeners._value
      .toBe null

  it "is bound to the Event", ->

    event = Event {async: no}

    listener = event 2, emptyFunction
    listener.start()

    emit = event.emit
    emit()

    expect listener.calls
      .toBe 1

  it "while notifying, any detached Listeners are cleaned up", ->

    event = Event {async: no}

    foo = event 1, ->

      foo.detach()
      bar.detach()

      # Before cleaning up, wait until finished notifying.
      expect event.listenerCount
        .toBe 2

    bar = event 1, emptyFunction

    foo.start()
    bar.start()

    event.emit()

    expect event.listenerCount
      .toBe 0

    expect foo.calls
      .toBe 1

    expect bar.calls
      .toBe 0

  bench ->

    event = Event {async: no}

    for i in [ 0 .. 5 ]
      event emptyFunction

    @add ".emit()", ->
      event.emit()

describe "Event.didAttach", ->

  it "does not call emit on itself when a Listener is attached", ->

    event = Event.didAttach
    spy = jasmine.createSpy()

    foo = event 5, emptyFunction
    foo.start()

    event emptyFunction

    expect foo.calls
      .toBe 0

    expect event.listenerCount
      .toBe 2
