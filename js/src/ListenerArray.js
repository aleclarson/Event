var Listener, Type, assert, assertType, emptyFunction, getArgProp, type;

emptyFunction = require("emptyFunction");

assertType = require("assertType");

getArgProp = require("getArgProp");

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
  _onUpdate: getArgProp("onUpdate"),
  _isNotifying: false,
  _detached: function() {
    return [];
  }
});

type.exposeGetters(["length", "isNotifying"]);

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
    oldValue = this._value;
    if (!oldValue) {
      return;
    }
    assert(!this._isNotifying, "ListenerArray is already notifying!");
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
  }
});

module.exports = type.build();

//# sourceMappingURL=../../map/src/ListenerArray.map
