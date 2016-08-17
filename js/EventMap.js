var Event, Type, assert, assertType, isType, mutable, steal, type;

require("isDev");

mutable = require("Property").mutable;

assertType = require("assertType");

isType = require("isType");

assert = require("assert");

steal = require("steal");

Type = require("Type");

Event = require("./Event");

type = Type("EventMap", function(eventName, maxCalls, onNotify) {
  var listener;
  listener = Event.Listener(maxCalls, onNotify);
  mutable.define(listener, "_eventName", {
    value: eventName
  });
  return listener.attach(this);
});

type.defineArgs({
  events: Object.isRequired
});

type.defineFrozenValues({
  emit: function() {
    var eventMap;
    eventMap = this;
    return function(eventName, args) {
      var listeners;
      assertType(eventName, String, "eventName");
      listeners = eventMap._listeners[eventName];
      assert(listeners, "Event named '" + eventName + "' does not exist!");
      if (isDev && args) {
        assert(isType(args.length, Number), "'args' must be an array-like object!");
        eventMap._validateArgs(eventName, args);
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
    var eventName, eventTypes, listeners, types;
    types = this._types;
    listeners = this._listeners;
    for (eventName in events) {
      eventTypes = events[eventName];
      assert(!listeners[eventName], "Event named '" + eventName + "' already exists!");
      eventTypes && (types[eventName] = eventTypes);
      listeners[eventName] = Event.ListenerArray();
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
  _validateArgs: function(eventName, args) {
    var argName, argType, argTypes, index;
    if (!(argTypes = this._types[eventName])) {
      return;
    }
    index = 0;
    for (argName in argTypes) {
      argType = argTypes[argName];
      assertType(args[index], argType, argName);
      index += 1;
    }
  }
});

module.exports = type.build();

//# sourceMappingURL=map/EventMap.map
