var Tracer, Type, emptyFunction, getArgProp, type;

require("isDev");

emptyFunction = require("emptyFunction");

getArgProp = require("getArgProp");

Tracer = require("tracer");

Type = require("Type");

type = Type("Listener");

type.optionTypes = {
  onEmit: Function,
  onStop: Function,
  maxCalls: Number
};

type.optionDefaults = {
  onStop: emptyFunction,
  maxCalls: 2e308
};

type.initArguments(function(args) {
  if (args[0] instanceof Function) {
    return args[0] = {
      onEmit: args[0]
    };
  }
});

type.defineFrozenValues({
  maxCalls: getArgProp("maxCalls")
});

type.defineValues({
  start: function() {
    return emptyFunction;
  },
  stop: function() {
    return this._stopImpl;
  },
  notify: function() {
    return this._getNotifyImpl();
  },
  calls: function() {
    if (this.maxCalls !== 2e308) {
      return 0;
    }
  },
  _defuse: function() {
    return this._defuseImpl;
  },
  _onEmit: getArgProp("onEmit"),
  _onStop: getArgProp("onStop"),
  _onDefuse: function() {
    return emptyFunction;
  }
});

if (isDev) {
  type.defineValues({
    _traceInit: function() {
      return Tracer("Listener()");
    }
  });
}

type.defineMethods({
  _getNotifyImpl: function() {
    if (this.maxCalls === 2e308) {
      return this._unlimitedImpl;
    }
    return this._limitedImpl;
  },
  _unlimitedImpl: function(context, args) {
    this._onEmit.apply(context, args);
  },
  _limitedImpl: function(context, args) {
    this.calls += 1;
    this._onEmit.apply(context, args);
    if (this.calls === this.maxCalls) {
      this.stop();
    }
  },
  _startImpl: function() {
    this.start = emptyFunction;
    this.notify = this._getNotifyImpl();
    this.stop = this._stopImpl;
    this._defuse = this._defuseImpl;
  },
  _stopImpl: function() {
    this._defuse();
    this._onStop(this);
  },
  _defuseImpl: function() {
    this.start = this._startImpl;
    this.notify = emptyFunction;
    this.stop = emptyFunction;
    this._defuse = emptyFunction;
    this._onDefuse();
  }
});

module.exports = type.build();

//# sourceMappingURL=../../map/src/Listener.map
