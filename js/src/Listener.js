var Factory, Listener, define, emptyFunction, isType;

isType = require("type-utils").isType;

emptyFunction = require("emptyFunction");

Factory = require("factory");

define = require("define");

module.exports = Listener = Factory("Listener", {
  optionTypes: {
    onEvent: Function,
    onStop: Function,
    maxCalls: Number
  },
  optionDefaults: {
    onStop: emptyFunction,
    maxCalls: Infinity
  },
  initArguments: function(options) {
    if (isType(options, Function)) {
      options = {
        onEvent: options
      };
    }
    return [options];
  },
  customValues: {
    calls: {
      get: function() {
        return this._calls;
      }
    }
  },
  initFrozenValues: function(options) {
    return {
      maxCalls: options.maxCalls,
      _onEvent: options.onEvent,
      _onStop: options.onStop
    };
  },
  init: function() {
    var isLimited;
    return isLimited = this.maxCalls === Infinity ? this.notify = this._notifyUnlimited : (define(this, "_calls", 0), this.notify = this._notifyLimited);
  },
  stop: function() {
    this._defuse();
    this._onStop(this);
  },
  _notifyUnlimited: function(scope, args) {
    this._onEvent.apply(scope, args);
  },
  _notifyLimited: function(scope, args) {
    this._calls += 1;
    this._onEvent.apply(scope, args);
    if (this._calls === this.maxCalls) {
      this.stop();
    }
  },
  _defuse: function() {
    this.notify = emptyFunction.thatReturnsFalse;
    this._defuse = this.stop = emptyFunction;
  }
});

//# sourceMappingURL=../../map/src/Listener.map
