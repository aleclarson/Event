var Event;

Event = require("../src/Event");

describe("listener.notify()", function() {
  it("calls the `_onNotify` property", function() {
    var event, listener, spy;
    event = Event();
    listener = event(spy = jasmine.createSpy());
    listener.start();
    listener.notify();
    return expect(spy.calls.count()).toBe(1);
  });
  it("increments the `calls` property if `maxCalls` isnt Infinity", function() {
    var event, listener;
    event = Event();
    listener = event(3, emptyFunction);
    listener.start();
    listener.notify();
    expect(listener.calls).toBe(1);
    listener.notify();
    return expect(listener.calls).toBe(2);
  });
  return it("detaches the Listener if `maxCalls` is reached", function() {
    var event, listener;
    event = Event();
    listener = event(1, emptyFunction);
    listener.start();
    listener.notify();
    listener.notify();
    return expect(listener.calls).toBe(1);
  });
});

describe("listener.detach()", function() {
  it("unpairs the Listener from its Event", function() {
    var event, listener;
    event = Event();
    listener = event(5, emptyFunction);
    listener.start();
    event.emit();
    listener.detach();
    expect(listener._event).toBe(null);
    event.emit();
    expect(event.listenerCount).toBe(0);
    return expect(listener.calls).toBe(1);
  });
  return it("can be safely called multiple times", function() {
    var event, listener;
    event = Event();
    listener = event(emptyFunction);
    listener.start();
    listener.detach();
    return expect(function() {
      return listener.detach();
    }).not.toThrow();
  });
});

describe("listener.stop()", function() {
  it("disables the Listener without detaching it", function() {
    var event, listener;
    event = Event();
    listener = event(5, emptyFunction);
    listener.start();
    event.emit();
    listener.stop();
    expect(listener._event).toBe(event);
    event.emit();
    expect(event.listenerCount).toBe(1);
    return expect(listener.calls).toBe(1);
  });
  return it("can be safely called multiple times", function() {
    var event, listener;
    event = Event();
    listener = event(emptyFunction);
    listener.start();
    listener.stop();
    return expect(function() {
      return listener.stop();
    }).not.toThrow();
  });
});

//# sourceMappingURL=../../map/spec/Listener.map
