var Factory, Listener, emptyFunction, isType;

isType = require("type-utils").isType;

emptyFunction = require("emptyFunction");

Factory = require("factory");

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
  initValues: function() {
    return {
      _calls: 0
    };
  },
  notify: function(scope, args) {
    this._calls += 1;
    this._onEvent.apply(scope, args);
    if (this._calls < this.maxCalls) {
      return true;
    }
    this._defuse();
    return false;
  },
  stop: function() {
    this._defuse();
    this._onStop();
  },
  _defuse: function() {
    this._prevent = this.notify = this.stop = emptyFunction;
  }
});

//# sourceMappingURL=../../map/src/Listener.map
