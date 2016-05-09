var Event, LazyVar, Listener, Tracer, Type, assert, assertType, emptyFunction, guard, isType, ref, throwFailure, type;

require("isDev");

ref = require("type-utils"), isType = ref.isType, assert = ref.assert, assertType = ref.assertType;

throwFailure = require("failure").throwFailure;

emptyFunction = require("emptyFunction");

LazyVar = require("lazy-var");

Tracer = require("tracer");

guard = require("guard");

Type = require("Type");

type = Type("Event", function(onEvent) {
  return this._attachListener(Listener({
    onEvent: onEvent,
    onStop: this._detachListener
  }));
});

type.optionTypes = {
  onEvent: Function.Maybe,
  onSetListeners: Function.Maybe,
  maxRecursion: Number
};

type.optionDefaults = {
  maxRecursion: 0
};

type.createArguments(function(args) {
  if (isType(args[0], Function)) {
    args[0] = {
      onEvent: args[0]
    };
  }
  return args;
});

type.defineProperties({
  listenerCount: {
    get: function() {
      return this._listenerCount;
    }
  },
  emit: {
    lazy: function() {
      var self;
      self = this;
      return function() {
        var args, scope, traceEmit;
        if (isDev) {
          traceEmit = Tracer("Event::emit()");
        }
        scope = self === this ? null : this;
        args = arguments;
        return guard((function(_this) {
          return function() {
            return self._notifyListeners(scope, args);
          };
        })(this)).fail((function(_this) {
          return function(error) {
            return throwFailure(error, {
              event: self,
              stack: [traceEmit(), _this._traceInit()]
            });
          };
        })(this));
      };
    }
  },
  emitArgs: {
    lazy: function() {
      var self;
      self = this;
      return function(args) {
        var scope, traceEmit;
        if (isDev) {
          traceEmit = Tracer("Event::emitArgs()");
        }
        scope = self === this ? null : this;
        return guard((function(_this) {
          return function() {
            return self._notifyListeners(scope, args);
          };
        })(this)).fail((function(_this) {
          return function(error) {
            return throwFailure(error, {
              stack: [traceEmit(), _this._traceInit()],
              event: self
            });
          };
        })(this));
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
});

type.defineValues({
  _isNotifying: false,
  _recursionCount: 0,
  _maxRecursion: function(options) {
    return options.maxRecursion;
  },
  _detachQueue: [],
  _listeners: null,
  _onSetListeners: function(options) {
    return options.onSetListeners;
  }
});

if (isDev) {
  type.defineValues({
    _traceInit: function() {
      return Tracer("Event()");
    }
  });
}

type.defineReactiveValues({
  _listenerCount: 0
});

type.initInstance(function(options) {
  if (options.onEvent) {
    return this(options.onEvent);
  }
});

type.bindMethods(["_detachListener"]);

type.defineMethods({
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
    var i, len, listener, oldValue;
    oldValue = this._listeners;
    if (!oldValue) {
      return;
    }
    if (oldValue.constructor === Listener) {
      oldValue._defuse();
    } else {
      for (i = 0, len = oldValue.length; i < len; i++) {
        listener = oldValue[i];
        listener._defuse();
      }
    }
    this._setListeners(null, 0);
  },
  _attachListener: function(listener) {
    var oldValue;
    assertType(listener, Listener);
    oldValue = this._listeners;
    if (!oldValue) {
      this._setListeners(listener, 1);
    } else if (oldValue.constructor === Listener) {
      this._setListeners([oldValue, listener], 2);
    } else {
      oldValue.push(listener);
      this._setListeners(oldValue, oldValue.length);
    }
    this._onListen(listener);
    return listener;
  },
  _onListen: function(listener) {
    return Event._didListen.get().emit(this, listener);
  },
  _notifyListeners: function(scope, args) {
    var i, len, listener, oldValue, wasNotifying;
    oldValue = this._listeners;
    if (!oldValue) {
      return;
    }
    if (wasNotifying = this._isNotifying) {
      this._recursionCount += 1;
      assert(this._recursionCount <= this._maxRecursion, {
        reason: "Event is stuck in infinite recursion!"
      });
    } else {
      this._isNotifying = true;
    }
    if (oldValue.constructor === Listener) {
      oldValue.notify(scope, args);
    } else {
      for (i = 0, len = oldValue.length; i < len; i++) {
        listener = oldValue[i];
        listener.notify(scope, args);
      }
    }
    if (!wasNotifying) {
      this._isNotifying = false;
      this._recursionCount = 0;
    }
    return this._detachListeners(this._detachQueue);
  },
  _detachListener: function(listener) {
    var index, newCount, oldValue;
    if (this._isNotifying) {
      this._detachQueue.push(listener);
      return;
    }
    assert(this._listeners, "No listeners are attached!");
    oldValue = this._listeners;
    if (oldValue.constructor === Listener) {
      assert(listener === oldValue);
      this._setListeners(null, 0);
    } else {
      index = oldValue.indexOf(listener);
      assert(index >= 0);
      oldValue.splice(index, 1);
      newCount = oldValue.length;
      if (newCount === 1) {
        this._setListeners(oldValue[0], 1);
      } else {
        this._setListeners(oldValue, newCount);
      }
    }
  },
  _detachListeners: function(listeners) {
    var count, i, len, listener;
    count = listeners.length;
    if (count === 0) {
      return;
    }
    if (count === 1) {
      this._detachListener(listeners[0]);
    } else {
      for (i = 0, len = listeners.length; i < len; i++) {
        listener = listeners[i];
        this._detachListener(listener);
      }
    }
    return listeners.length = 0;
  },
  _setListeners: function(newValue, newCount) {
    assert(newCount !== this._listenerCount);
    if (newValue !== this._listeners) {
      this._listeners = newValue;
    }
    this._listenerCount = newCount;
    if (!this._onSetListeners) {
      return;
    }
    return this._onSetListeners(newValue, newCount);
  }
});

type.defineStatics({
  Listener: Listener = require("./Listener"),
  didListen: {
    get: function() {
      return this._didListen.get().listenable;
    }
  },
  _didListen: LazyVar(function() {
    var event;
    event = Event();
    event._onListen = emptyFunction;
    return event;
  })
});

module.exports = Event = type.build();

//# sourceMappingURL=../../map/src/Event.map
