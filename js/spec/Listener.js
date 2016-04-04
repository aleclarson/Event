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
    return it("detaches the Listener if 'maxCalls' is reached", function() {
      var event, listener;
      event = Event();
      listener = event.once(emptyFunction);
      listener.notify();
      listener.notify();
      return expect(listener.calls).toBe(1);
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
});

//# sourceMappingURL=../../map/spec/Listener.map
