var Event;

Event = require("../src/Event");

describe("Listener", function() {
  describe(".notify()", function() {
    it("calls the '_onEvent' property", function() {
      var event, listener;
      event = Event();
      listener = event(jasmine.createSpy());
      listener.notify();
      return expect(listener._onEvent.calls.count()).toBe(1);
    });
    it("increments the 'calls' property", function() {
      var event, listener;
      event = Event();
      listener = event(emptyFunction);
      listener.notify();
      expect(listener.calls).toBe(1);
      listener.notify();
      return expect(listener.calls).toBe(2);
    });
    it("returns true if the Listener is still attached", function() {
      var event, listener;
      event = Event();
      listener = event.many(2, emptyFunction);
      expect(listener.notify()).toBe(true);
      return expect(listener.notify()).toBe(false);
    });
    return it("detaches the Listener if 'maxCalls' is reached", function() {
      var event, listener;
      event = Event();
      listener = event.once(emptyFunction);
      listener.notify();
      listener.notify();
      expect(listener.calls).toBe(1);
      expect(listener.notify).toBe(emptyFunction);
      return expect(listener.stop).toBe(emptyFunction);
    });
  });
  return describe(".stop()", function() {
    it("detaches the Listener", function() {
      var event, listener;
      event = Event();
      listener = event(emptyFunction);
      event.emit();
      listener.stop();
      event.emit();
      expect(listener.calls).toBe(1);
      expect(listener.notify).toBe(emptyFunction);
      return expect(listener.stop).toBe(emptyFunction);
    });
    it("can be safely called multiple times", function() {
      var event, listener;
      event = Event();
      listener = event(emptyFunction);
      listener.stop();
      return expect(function() {
        return listener.stop();
      }).not.toThrow();
    });
    it("works inside the Listener", function() {
      var bar, event, foo;
      event = Event();
      foo = event(function() {
        return foo.stop();
      });
      bar = event(emptyFunction);
      event.emit();
      event.emit();
      expect(foo.calls).toBe(1);
      return expect(bar.calls).toBe(2);
    });
    return it("works inside another Listener", function() {
      var bar, event, foo;
      event = Event();
      foo = event(emptyFunction);
      bar = event(function() {
        return foo.stop();
      });
      event.emit();
      event.emit();
      expect(foo.calls).toBe(1);
      return expect(bar.calls).toBe(2);
    });
  });
});

//# sourceMappingURL=../../map/spec/Listener.map
