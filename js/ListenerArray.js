var Listener, Type, assert, assertType, emptyFunction, fromArgs, immediate, type;

emptyFunction = require("emptyFunction");

assertType = require("assertType");

immediate = require("immediate");

fromArgs = require("fromArgs");

assert = require("assert");

Type = require("Type");

Listener = require("./Listener");

type = Type("ListenerArray");

type.defineOptions({
  onUpdate: {
    type: Function,
    "default": emptyFunction
  }
});

type.defineValues({
  _value: null,
  _length: 0,
  _onUpdate: fromArgs("onUpdate"),
  _isNotifying: false,
  _queue: function() {
    return [];
  },
  _detached: function() {
    return [];
  }
});

type.defineGetters({
  length: function() {
    return this._length;
  },
  isNotifying: function() {
    return this._isNotifying;
  }
});

type.defineMethods({
  attach: function(listener) {
    var oldValue;
    assertType(listener, Listener);
    if (!(oldValue = this._value)) {
      this._update(listener, 1);
      return;
    }
    if (oldValue.constructor === Listener) {
      this._update([oldValue, listener], 2);
      return;
    }
    this._update(oldValue, oldValue.push(listener));
  },
  notify: function(context, args) {
    var i, len, listener, oldValue;
    if (this._isNotifying || this._queue.length) {
      this._queue.push([context, args]);
      return;
    }
    oldValue = this._value;
    if (!oldValue) {
      return;
    }
    this._isNotifying = true;
    if (oldValue.constructor === Listener) {
      oldValue.notify(context, args);
    } else {
      for (i = 0, len = oldValue.length; i < len; i++) {
        listener = oldValue[i];
        listener.notify(context, args);
      }
    }
    this._isNotifying = false;
    this._flush();
    immediate((function(_this) {
      return function() {
        return _this._next();
      };
    })(this));
  },
  detach: function(listener) {
    var index, newCount, oldValue;
    assertType(listener, Listener);
    if (this._isNotifying) {
      this._detached.push(listener);
      return;
    }
    oldValue = this._value;
    assert(oldValue, "No listeners are attached!");
    if (oldValue.constructor === Listener) {
      assert(listener === oldValue, "Listener is not attached to this ListenerArray!");
      this._update(null, 0);
      return;
    }
    index = oldValue.indexOf(listener);
    assert(index >= 0, "Listener is not attached to this ListenerArray!");
    oldValue.splice(index, 1);
    newCount = oldValue.length;
    if (newCount === 1) {
      this._update(oldValue[0], 1);
    } else {
      this._update(oldValue, newCount);
    }
  },
  reset: function() {
    if (this._length) {
      this._update(null, 0);
    }
  },
  _update: function(newValue, newLength) {
    this._value = newValue;
    this._length = newLength;
    this._onUpdate(newValue, newLength);
  },
  _flush: function() {
    var index, length, listeners;
    length = (listeners = this._detached).length;
    if (length === 0) {
      return;
    }
    if (length === 1) {
      this.detach(listeners.pop());
      return;
    }
    index = -1;
    while (++index < length) {
      this.detach(listeners[index]);
    }
    listeners.length = 0;
  },
  _next: function() {
    var args, context, queue, ref;
    queue = this._queue;
    if (!queue.length) {
      return;
    }
    ref = queue.shift(), context = ref[0], args = ref[1];
    this.notify(context, args);
  }
});

module.exports = type.build();

//# sourceMappingURL=map/ListenerArray.map
