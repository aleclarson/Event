// Generated by CoffeeScript 1.11.1
var Event, ListenerArray, Type, assertType, bind, frozen, isDev, isType, type, validateArgs;

frozen = require("Property").frozen;

assertType = require("assertType");

isType = require("isType");

isDev = require("isDev");

Type = require("Type");

bind = require("bind");

ListenerArray = require("./ListenerArray");

type = Type("Event");

type.trace();

type.initArgs(function(args) {
  if (isType(args[0], Object)) {
    args[1] = args[0];
    args[0] = void 0;
  } else if (!args[1]) {
    args[1] = {};
  }
});

type.defineArgs({
  callback: Function,
  options: {
    async: Boolean,
    argTypes: Object
  }
});

type.defineFunction(function(maxCalls, callback) {
  return Event.Listener(maxCalls, callback).attach(this);
});

type.defineFrozenValues(function(_, options) {
  return {
    _async: options.async,
    _argTypes: options.argTypes
  };
});

type.initInstance(function(callback) {
  return callback && Event.Listener(callback).attach(this).start();
});

type.defineGetters({
  listenable: function() {
    return this._listenable || this._createListenable();
  },
  listenerCount: function() {
    if (this._listeners) {
      return this._listeners.length;
    } else {
      return 0;
    }
  },
  hasListeners: function() {
    return this.listenerCount > 0;
  }
});

type.defineMethods({
  emit: function() {
    isDev && validateArgs(arguments, this._argTypes);
    this._listeners && this._listeners.notify(arguments);
  },
  bindEmit: function() {
    return this._boundEmit || this._createBoundEmit();
  },
  applyEmit: function(args) {
    return this.emit.apply(this, args);
  },
  reset: function() {
    this._listeners && this._listeners.reset();
  },
  _onAttach: function(listener) {
    var listeners;
    listeners = this._listeners || this._createListeners();
    listeners.attach(listener);
    Event.didAttach.emit(listener, this);
  },
  _onDetach: function(listener) {
    this._listeners.detach(listener);
  },
  _createBoundEmit: function() {
    frozen.define(this, "_boundEmit", {
      value: bind.method(this, "emit")
    });
    return this._boundEmit;
  },
  _createListenable: function() {
    frozen.define(this, "_listenable", {
      value: (function(_this) {
        return function(maxCalls, callback) {
          return Event.Listener(maxCalls, callback).attach(_this);
        };
      })(this)
    });
    return this._listenable;
  },
  _createListeners: function() {
    frozen.define(this, "_listeners", {
      value: ListenerArray({
        async: this._async
      })
    });
    return this._listeners;
  }
});

type.defineStatics({
  didAttach: {
    get: function() {
      frozen.define(this, "didAttach", {
        value: Event()
      });
      frozen.define(this.didAttach, "_onAttach", {
        value: function(listener) {
          var listeners;
          listeners = this._listeners || this._createListeners();
          listeners.attach(listener);
        }
      });
      return this.didAttach;
    }
  }
});

module.exports = Event = type.build();

validateArgs = function(args, argTypes) {
  var argNames, i, index, len, name;
  if (!argTypes) {
    return;
  }
  argNames = Object.keys(argTypes);
  for (index = i = 0, len = argNames.length; i < len; index = ++i) {
    name = argNames[index];
    assertType(args[index], argTypes[name], name);
  }
};
