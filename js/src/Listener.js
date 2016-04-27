var Factory, Listener, Tracer, define, emptyFunction, guard, isType;

require("isDev");

isType = require("type-utils").isType;

emptyFunction = require("emptyFunction");

Factory = require("factory");

define = require("define");

Tracer = require("tracer");

guard = require("guard");

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
  initValues: function(options) {
    return {
      _onDefuse: emptyFunction,
      _traceInit: isDev ? Tracer("Listener()") : void 0
    };
  },
  init: function() {
    if (this.maxCalls === Infinity) {
      return this.notify = this._notifyUnlimited;
    } else {
      define(this, "_calls", 0);
      return this.notify = this._notifyLimited;
    }
  },
  stop: function() {
    this._defuse();
    this._onStop(this);
  },
  _notifyUnlimited: function(scope, args) {
    guard((function(_this) {
      return function() {
        return _this._onEvent.apply(scope, args);
      };
    })(this)).fail((function(_this) {
      return function(error) {
        return throwFailure(error, {
          scope: scope,
          args: args,
          listener: _this
        });
      };
    })(this));
  },
  _notifyLimited: function(scope, args) {
    this._calls += 1;
    guard((function(_this) {
      return function() {
        return _this._onEvent.apply(scope, args);
      };
    })(this)).fail((function(_this) {
      return function(error) {
        return throwFailure(error, {
          scope: scope,
          args: args,
          listener: _this
        });
      };
    })(this));
    if (this._calls === this.maxCalls) {
      this.stop();
    }
  },
  _defuse: function() {
    this.notify = emptyFunction.thatReturnsFalse;
    this._defuse = this.stop = emptyFunction;
    this._onDefuse();
  }
});

//# sourceMappingURL=../../map/src/Listener.map
