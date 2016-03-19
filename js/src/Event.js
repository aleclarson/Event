var Event, Factory, LazyVar, Listener, Void, assertType, didListen, emptyFunction, isType, ref, throwFailure;

ref = require("type-utils"), Void = ref.Void, isType = ref.isType, assertType = ref.assertType;

throwFailure = require("failure").throwFailure;

emptyFunction = require("emptyFunction");

LazyVar = require("lazy-var");

Factory = require("factory");

Listener = require("./Listener");

didListen = LazyVar(function() {
  var event;
  event = Event();
  event._onListen = emptyFunction;
  return event;
});

module.exports = Event = Factory("Event", {
  statics: {
    Listener: Listener,
    didListen: {
      get: function() {
        return didListen.get().listenable;
      }
    }
  },
  initArguments: function(options) {
    assertType(options, [Object, Function, Void]);
    if (options == null) {
      options = {};
    } else if (isType(options, Function)) {
      options = {
        onEvent: options
      };
    }
    return [options];
  },
  optionTypes: {
    onEvent: [Function, Void]
  },
  customValues: {
    emit: {
      lazy: function() {
        var self;
        self = this;
        return function() {
          return self._notifyListeners(this, arguments);
        };
      }
    },
    emitArgs: {
      lazy: function() {
        var self;
        self = this;
        return function(args) {
          return self._notifyListeners(this, args);
        };
      }
    },
    listenable: {
      lazy: function() {
        var self;
        self = (function(_this) {
          return function(options) {
            return _this(options);
          };
        })(this);
        self.once = (function(_this) {
          return function(options) {
            return _this.once(options);
          };
        })(this);
        return self;
      }
    }
  },
  initValues: function() {
    return {
      _listeners: null
    };
  },
  init: function(options) {
    if (options.onEvent != null) {
      return this(options.onEvent);
    }
  },
  boundMethods: ["_detachListener"],
  func: function(onEvent) {
    return this._attachListener(Listener({
      onEvent: onEvent,
      onStop: this._detachListener
    }));
  },
  once: function(onEvent) {
    return this._attachListener(Listener({
      onEvent: onEvent,
      maxCalls: 1,
      onStop: this._detachListener
    }));
  },
  many: function(maxCalls, onEvent) {
    return this._attachListener(Listener({
      onEvent: onEvent,
      maxCalls: maxCalls,
      onStop: this._detachListener
    }));
  },
  reset: function() {
    var i, len, listener, listeners;
    listeners = this._listeners;
    if (!listeners) {
      return;
    }
    if (isType(listeners, Listener)) {
      listeners._defuse();
    } else {
      for (i = 0, len = listeners.length; i < len; i++) {
        listener = listeners[i];
        listener._defuse();
      }
    }
    this._listeners = null;
  },
  _attachListener: function(listener) {
    assertType(listener, Listener);
    this._listeners = this._retainListener(listener, this._listeners);
    this._onListen(listener);
    return listener;
  },
  _retainListener: function(listener, oldValue) {
    if (!oldValue) {
      return listener;
    }
    if (isType(oldValue, Listener)) {
      return [oldValue, listener];
    }
    oldValue.push(listener);
    return oldValue;
  },
  _onListen: function(listener) {
    return didListen.get().emit(this, listener);
  },
  _notifyListeners: function(scope, args) {
    var listeners;
    listeners = this._listeners;
    if (!listeners) {
      return;
    }
    if (isType(listeners, Listener)) {
      if (listeners.notify(scope, args)) {
        return;
      }
      this._listeners = null;
    } else {
      listeners = listeners.filter(function(listener) {
        return listener.notify(scope, args);
      });
      if (listeners.length === 0) {
        this._listeners = null;
      } else if (listeners.length === 1) {
        this._listeners = listeners[0];
      } else {
        this._listeners = listeners;
      }
    }
  },
  _detachListener: function(listener) {
    var index, listeners;
    listeners = this._listeners;
    if (isType(listeners, Listener)) {
      if (listener !== listeners) {
        return;
      }
      this._listeners = null;
    } else {
      index = listeners.indexOf(listener);
      if (index < 0) {
        return;
      }
      listeners.splice(index, 1);
      if (listeners.length > 1) {
        return;
      }
      this._listeners = listeners[0];
    }
  }
});

//# sourceMappingURL=../../map/src/Event.map
