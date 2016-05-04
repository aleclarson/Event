var Tracer, Type, emptyFunction, guard, isType, type;

isType = require("type-utils").isType;

emptyFunction = require("emptyFunction");

Tracer = require("tracer");

guard = require("guard");

Type = require("Type");

type = Type("Listener");

type.optionTypes = {
  onEvent: Function,
  onStop: Function,
  maxCalls: Number
};

type.optionDefaults = {
  onStop: emptyFunction,
  maxCalls: Infinity
};

type.createArguments(function(args) {
  if (isType(args[0], Function)) {
    args[0] = {
      onEvent: args[0]
    };
  }
  return args;
});

type.defineFrozenValues({
  maxCalls: function(options) {
    return options.maxCalls;
  },
  _onEvent: function(options) {
    return options.onEvent;
  },
  _onStop: function(options) {
    return options.onStop;
  }
});

type.defineValues({
  _onDefuse: function() {
    return emptyFunction;
  },
  _traceInit: function() {
    if (isDev) {
      return Tracer("Listener()");
    }
  }
});

type.initInstance(function() {
  if (this.maxCalls === Infinity) {
    this.notify = this._notifyUnlimited;
    return;
  }
  this.notify = this._notifyLimited;
  return this.calls = 0;
});

type.defineMethods({
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

module.exports = type.build();

//# sourceMappingURL=../../map/src/Listener.map
