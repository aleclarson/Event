var Event, Type, assertType, isType, mutable, type;

require("isDev");

mutable = require("Property").mutable;

assertType = require("assertType");

isType = require("isType");

Type = require("Type");

Event = require("./Event");

type = Type("EventMap");

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
      if (isDev) {
        if (!listeners) {
          throw Error("Event named '" + eventName + "' does not exist!");
        }
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

type.defineFunction(function(eventName, maxCalls, callback) {
  var listener;
  listener = Event.Listener(maxCalls, callback);
  mutable.define(listener, "_eventName", {
    value: eventName
  });
  return listener.attach(this);
});

type.defineMethods({
  _addEvents: function(events) {
    var eventName, eventTypes, listeners, types;
    types = this._types;
    listeners = this._listeners;
    for (eventName in events) {
      eventTypes = events[eventName];
      if (isDev && listeners[eventName]) {
        throw Error("Event named '" + eventName + "' already exists!");
      }
      eventTypes && (types[eventName] = eventTypes);
      listeners[eventName] = Event.ListenerArray();
    }
  },
  _onAttach: function(listener) {
    if (isDev && !this._listeners[listener._eventName]) {
      throw Error("Invalid event name: '" + listener._eventName + "'");
    }
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
    argTypes = this._types[eventName];
    if (!argTypes) {
      return;
    }
    if (isDev && !isType(args.length, Number)) {
      throw Error("'args' must be an array-like object!");
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
