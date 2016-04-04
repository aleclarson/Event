var Event;

Event = require("../src/Event");

describe("Event", function() {
  describe(".call()", function() {
    it("returns a Listener", function() {
      var event, listener;
      event = Event();
      listener = event(emptyFunction);
      return expect(getType(listener)).toBe(Event.Listener);
    });
    return it("lazily converts to array storage", function() {
      var event, listener;
      event = Event();
      listener = event(emptyFunction);
      expect(getType(event._listeners)).toBe(Event.Listener);
      listener = event(emptyFunction);
      return expect(getType(event._listeners)).toBe(Array);
    });
  });
  describe(".once()", function() {
    return it("only calls the Listener once", function() {
      var event, listener;
      event = Event();
      listener = event.once(emptyFunction);
      event.emit();
      event.emit();
      return expect(listener.calls).toBe(1);
    });
  });
  describe(".many()", function() {
    return it("calls the Listener the correct number of times", function() {
      var event, listener;
      event = Event();
      listener = event.many(2, emptyFunction);
      event.emit();
      event.emit();
      event.emit();
      return expect(listener.calls).toBe(2);
    });
  });
  return describe(".emit()", function() {
    it("notifies every attached Listener", function() {
      var event, spy;
      spy = jasmine.createSpy();
      event = Event();
      event(spy);
      event(spy);
      event.emit();
      return expect(spy.calls.count()).toBe(2);
    });
    it("works with just one Listener", function() {
      var event, listener;
      event = Event();
      listener = event(emptyFunction);
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
      foo = event.many(2, emptyFunction);
      bar = event.once(emptyFunction);
      expect(event._listeners.length).toBe(2);
      event.emit();
      expect(event._listeners).toBe(foo);
      event.emit();
      return expect(event._listeners).toBe(null);
    });
    it("is bound to the Event", function() {
      var emit, event, listener;
      event = Event();
      listener = event(emptyFunction);
      emit = event.emit;
      emit();
      return expect(listener.calls).toBe(1);
    });
    it("can stop a listener during an emit", function() {
      var bar, event, foo, spy, zen;
      spy = jasmine.createSpy();
      event = Event();
      foo = event(function() {
        spy(0);
        return bar.stop();
      });
      bar = event(function() {
        return spy(1);
      });
      zen = event(function() {
        return spy(2);
      });
      event.emit();
      expect(spy.calls.count()).toBe(2);
      expect(spy.calls.argsFor(0)).toContain(0);
      return expect(spy.calls.argsFor(1)).toContain(2);
    });
    it("detaches a listener that stops itself", function() {
      var event, foo;
      event = Event();
      foo = event(function() {
        foo.stop();
        return expect(event.listenerCount).toBe(1);
      });
      event.emit();
      return expect(event.listenerCount).toBe(0);
    });
    it("detaches a listener that is stopped by an earlier listener", function() {
      var bar, event, foo, spy;
      event = Event();
      foo = event(function() {
        bar.stop();
        return expect(event.listenerCount).toBe(2);
      });
      bar = event(spy = jasmine.createSpy());
      event.emit();
      expect(event.listenerCount).toBe(1);
      return expect(spy.calls.count()).toBe(0);
    });
    it("detaches a listener that is stopped by a later listener", function() {
      var bar, event, foo;
      event = Event();
      foo = event(emptyFunction);
      bar = event(function() {
        foo.stop();
        return expect(event.listenerCount).toBe(2);
      });
      event.emit();
      return expect(event.listenerCount).toBe(1);
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
});

//# sourceMappingURL=../../map/spec/Event.map
