
Event = require "../src/Event"

describe "listener.notify()", ->

  it "calls the `_onNotify` property", ->

    event = Event()

    listener = event spy = jasmine.createSpy()
    listener.start()

    listener.notify()
    expect spy.calls.count()
      .toBe 1

  it "increments the `calls` property if `maxCalls` isnt Infinity", ->

    event = Event()

    listener = event 3, emptyFunction
    listener.start()

    listener.notify()
    expect listener.calls
      .toBe 1

    listener.notify()
    expect listener.calls
      .toBe 2

  it "detaches the Listener if `maxCalls` is reached", ->

    event = Event()

    listener = event 1, emptyFunction
    listener.start()

    listener.notify()
    listener.notify()
    expect listener.calls
      .toBe 1

describe "listener.detach()", ->

  it "unpairs the Listener from its Event", ->

    event = Event()

    listener = event 5, emptyFunction
    listener.start()

    event.emit()

    listener.detach()

    expect listener._event
      .toBe null

    event.emit()

    expect event.listenerCount
      .toBe 0

    expect listener.calls
      .toBe 1

  it "can be safely called multiple times", ->

    event = Event()

    listener = event emptyFunction
    listener.start()

    listener.detach()

    expect -> listener.detach()
      .not.toThrow()

describe "listener.stop()", ->

  it "disables the Listener without detaching it", ->

    event = Event()

    listener = event 5, emptyFunction
    listener.start()

    event.emit()

    listener.stop()

    expect listener._event
      .toBe event

    event.emit()

    expect event.listenerCount
      .toBe 1

    expect listener.calls
      .toBe 1

  it "can be safely called multiple times", ->

    event = Event()
    listener = event emptyFunction
    listener.start()

    listener.stop()

    expect -> listener.stop()
      .not.toThrow()
