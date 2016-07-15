var Event, Type, assert, assertType, mutable, steal, type;

require("isDev");

mutable = require("Property").mutable;

assertType = require("assertType");

assert = require("assert");

steal = require("steal");

Type = require("Type");

Event = require("./Event");

type = Type("EventMap", function(eventName, maxCalls, onNotify) {
  var listener;
  listener = Event.Listener(maxCalls, onNotify);
  mutable.define(listener, "_eventName", eventName);
  return listener.attach(this);
});

type.argumentTypes = {
  events: Object
};

type.defineFrozenValues({
  emit: function() {
    var eventMap;
    eventMap = this;
    return function(eventName, args) {
      var listeners;
      listeners = eventMap._listeners[eventName];
      assert(listeners, "Invalid event name!");
      assertType(eventName, String, "eventName");
      assert(typeof args.length === "number", "'args' must be an array-like object!");
      if (isDev && args) {
        eventMap._validateTypes(eventName, args);
      }
      listeners.notify(this, args);
    };
  },
  _listeners: function() {
    return Object.create(null);
  },
  _types: function() {
    return Object.create(null);
  }
});

type.initInstance(function(events) {
  return this._addEvents(events);
});

type.defineMethods({
  _addEvents: function(events) {
    var config, eventName;
    for (eventName in events) {
      config = events[eventName];
      if (config.types) {
        this._types[eventName] = steal(config, "types");
      }
      this._listeners[eventName] = Event.ListenerArray();
    }
  },
  _onAttach: function(listener) {
    assert(this._listeners[listener._eventName], "Invalid event name!");
    this._listeners[listener._eventName].attach(listener);
    Event.didAttach.emit(listener, this);
  },
  _onDetach: function(listener) {
    this._listeners[listener._eventName].detach(listener);
    listener._eventName = null;
  }
});

isDev && type.defineMethods({
  _validateTypes: function(event, args) {
    var index, key, types;
    types = this._types[event];
    if (!types) {
      return;
    }
    index = 0;
    for (key in types) {
      type = types[key];
      assertType(args[index], type, key);
      index += 1;
    }
  }
});

module.exports = type.build();

//# sourceMappingURL=map/EventMap.map
