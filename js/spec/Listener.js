var Event;

Event = require("../src/Event");

describe("listener.notify()", function() {
  it("calls the '_onNotify' property", function() {
    var event, listener;
    event = Event();
    listener = event(jasmine.createSpy());
    listener.notify();
    return expect(listener._onNotify.calls.count()).toBe(1);
  });
  it("increments the 'calls' property", function() {
    var event, listener;
    event = Event();
    listener = event.many(3, emptyFunction);
    listener.notify();
    expect(listener.calls).toBe(1);
    listener.notify();
    return expect(listener.calls).toBe(2);
  });
  return it("detaches the Listener if 'maxCalls' is reached", function() {
    var event, listener;
    event = Event();
    listener = event.once(emptyFunction);
    listener.notify();
    listener.notify();
    return expect(listener.calls).toBe(1);
  });
});

describe("listener.defuse()", function() {
  it("detaches the Listener from its Event", function() {
    var event, listener;
    event = Event();
    listener = event.many(5, emptyFunction);
    event.emit();
    listener.defuse();
    event.emit();
    expect(event.listenerCount).toBe(0);
    return expect(listener.calls).toBe(1);
  });
  return it("can be safely called multiple times", function() {
    var event, listener;
    event = Event();
    listener = event(emptyFunction);
    listener.defuse();
    return expect(function() {
      return listener.defuse();
    }).not.toThrow();
  });
});

describe("listener.stop()", function() {
  it("disables the Listener without defusing it", function() {
    var event, listener;
    event = Event();
    listener = event.many(5, emptyFunction);
    event.emit();
    listener.stop();
    event.emit();
    expect(event.listenerCount).toBe(1);
    return expect(listener.calls).toBe(1);
  });
  return it("can be safely called multiple times", function() {
    var event, listener;
    event = Event();
    listener = event(emptyFunction);
    listener.stop();
    return expect(function() {
      return listener.stop();
    }).not.toThrow();
  });
});

//# sourceMappingURL=../../map/spec/Listener.map
