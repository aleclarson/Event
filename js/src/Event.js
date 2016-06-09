var Event, Listener, Tracer, Type, assert, didListen, emptyFunction, getArgProp, type;

require("isDev");

emptyFunction = require("emptyFunction");

getArgProp = require("getArgProp");

Tracer = require("tracer");

assert = require("assert");

Type = require("Type");

type = Type("Event", function(onNotify) {
  return this._createListener(2e308, onNotify);
});

type.optionTypes = {
  onNotify: Function.Maybe,
  onSetListeners: Function,
  maxRecursion: Number
};

type.optionDefaults = {
  onSetListeners: emptyFunction,
  maxRecursion: 0
};

type.createArguments(function(args) {
  if (args[0] instanceof Function) {
    args[0] = {
      onNotify: args[0]
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
    get: function() {
      return this._boundEmit || (this._boundEmit = this._bindEmit());
    }
  },
  emitArgs: {
    get: function() {
      return this._boundEmitArgs || (this._boundEmitArgs = this._bindEmitArgs());
    }
  },
  listenable: {
    get: function() {
      return this._listenable || (this._listenable = this._createListenable());
    }
  }
});

type.defineValues({
  _isNotifying: false,
  _listenerCount: 0,
  _recursionCount: 0,
  _maxRecursion: getArgProp("maxRecursion"),
  _detachQueue: [],
  _listeners: null,
  _onSetListeners: getArgProp("onSetListeners"),
  _boundEmit: null,
  _boundEmitArgs: null,
  _listenable: null
});

isDev && type.defineValues({
  _traceInit: function() {
    return Tracer("Event()");
  }
});

type.initInstance(function(options) {
  if (options.onNotify) {
    return this._createListener(2e308, options.onNotify);
  }
});

type.bindMethods(["_detachListener"]);

type.defineMethods({
  once: function(onNotify) {
    return this._createListener(1, onNotify);
  },
  many: function(maxCalls, onNotify) {
    return this._createListener(maxCalls, onNotify);
  },
  reset: function() {
    if (this._listenerCount === 0) {
      return;
    }
    this._setListeners(null, 0);
  },
  _bindEmit: function() {
    var event;
    event = this;
    return function() {
      event._notifyListeners(this, arguments);
    };
  },
  _bindEmitArgs: function() {
    var event;
    event = this;
    return function(args) {
      event._notifyListeners(this, args);
    };
  },
  _createListenable: function() {
    var event, self;
    event = this;
    self = function(onNotify) {
      return event._createListener(2e308, onNotify);
    };
    self.once = function(onNotify) {
      return event._createListener(1, onNotify);
    };
    return self;
  },
  _createListener: function(maxCalls, onNotify) {
    var listener;
    listener = Listener(maxCalls, onNotify, this._detachListener);
    this._attachListener(listener);
    return listener;
  },
  _attachListener: function(listener) {
    var oldValue;
    oldValue = this._listeners;
    if (!oldValue) {
      this._setListeners(listener, 1);
    } else if (oldValue.constructor === Listener) {
      this._setListeners([oldValue, listener], 2);
    } else {
      oldValue.push(listener);
      this._setListeners(oldValue, oldValue.length);
    }
    this._didListen(listener);
  },
  _didListen: function(listener) {
    didListen.emit(listener, this);
  },
  _notifyListeners: function(context, args) {
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
      oldValue.notify(context, args);
    } else {
      for (i = 0, len = oldValue.length; i < len; i++) {
        listener = oldValue[i];
        listener.notify(context, args);
      }
    }
    if (!wasNotifying) {
      this._isNotifying = false;
      this._recursionCount = 0;
    }
    this._detachListeners(this._detachQueue);
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
    listeners.length = 0;
  },
  _setListeners: function(newValue, newCount) {
    assert(newCount !== this._listenerCount);
    this._listeners = newValue;
    this._listenerCount = newCount;
    this._onSetListeners(newValue, newCount);
  }
});

type.defineStatics({
  Listener: Listener = require("./Listener"),
  didListen: {
    get: function() {
      return didListen.listenable;
    }
  }
});

module.exports = Event = type.build();

didListen = Event();

didListen._didListen = emptyFunction;

//# sourceMappingURL=../../map/src/Event.map
