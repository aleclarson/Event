var Event, getType;

getType = require("getType");

Event = require("../src/Event");

describe("event(callback)", function() {
  it("returns a Listener", function() {
    var event, listener;
    event = Event();
    listener = event(emptyFunction);
    return expect(getType(listener)).toBe(Event.Listener);
  });
  it("lazily converts to array storage", function() {
    var bar, event, foo;
    event = Event();
    foo = event(emptyFunction);
    foo.start();
    expect(event._listeners._value).toBe(foo);
    bar = event(emptyFunction);
    bar.start();
    return expect(event._listeners._value).toEqual([foo, bar]);
  });
  it("supports stopping the Listener after one emit", function() {
    var event, listener;
    event = Event();
    listener = event(1, emptyFunction);
    listener.start();
    event.emit();
    event.emit();
    return expect(listener.calls).toBe(1);
  });
  return it("supports stopping the Listener after X emits", function() {
    var event, listener;
    event = Event();
    listener = event(2, emptyFunction);
    listener.start();
    event.emit();
    event.emit();
    event.emit();
    return expect(listener.calls).toBe(2);
  });
});

describe("event.emit(args...)", function() {
  it("notifies every attached Listener", function() {
    var bar, event, foo;
    event = Event();
    foo = event(1, emptyFunction);
    foo.start();
    bar = event(1, emptyFunction);
    bar.start();
    event.emit();
    expect(foo.calls).toBe(1);
    return expect(bar.calls).toBe(1);
  });
  it("works with just one Listener", function() {
    var event, listener;
    event = Event();
    listener = event(2, emptyFunction);
    listener.start();
    event.emit();
    return expect(listener.calls).toBe(1);
  });
  it("works with no listeners", function() {
    var event;
    event = Event();
    return expect(function() {
      return event.emit();
    }).not.toThrow();
  });
  it("detaches finished Listeners", function() {
    var bar, event, foo;
    event = Event();
    foo = event(2, emptyFunction);
    foo.start();
    bar = event(1, emptyFunction);
    bar.start();
    expect(event.listenerCount).toBe(2);
    event.emit();
    expect(event._listeners._value).toBe(foo);
    event.emit();
    return expect(event._listeners._value).toBe(null);
  });
  it("is bound to the Event", function() {
    var emit, event, listener;
    event = Event();
    listener = event(2, emptyFunction);
    listener.start();
    emit = event.emit;
    emit();
    return expect(listener.calls).toBe(1);
  });
  it("while notifying, any detached Listeners are cleaned up", function() {
    var bar, event, foo;
    event = Event();
    foo = event(1, function() {
      foo.detach();
      bar.detach();
      return expect(event.listenerCount).toBe(2);
    });
    bar = event(1, emptyFunction);
    foo.start();
    bar.start();
    event.emit();
    expect(event.listenerCount).toBe(0);
    expect(foo.calls).toBe(1);
    return expect(bar.calls).toBe(0);
  });
  return bench(function() {
    var event, i, j;
    event = Event();
    for (i = j = 0; j <= 5; i = ++j) {
      event(emptyFunction);
    }
    return this.add(".emit()", function() {
      return event.emit();
    });
  });
});

describe("Event.didAttach", function() {
  return it("does not call emit on itself when a Listener is attached", function() {
    var event, foo, spy;
    event = Event.didAttach;
    spy = jasmine.createSpy();
    foo = event(5, emptyFunction);
    foo.start();
    event(emptyFunction);
    expect(foo.calls).toBe(0);
    return expect(event.listenerCount).toBe(2);
  });
});

//# sourceMappingURL=../../map/spec/Event.map
