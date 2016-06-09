var Tracer, Type, emptyFunction, getArgProp, type;

require("isDev");

emptyFunction = require("emptyFunction");

getArgProp = require("getArgProp");

Tracer = require("tracer");

Type = require("Type");

type = Type("EventListener");

type.initArguments(function(args) {
  if (args[0] instanceof Function) {
    args[1] = args[0];
    return args[0] = void 0;
  }
});

type.argumentTypes = {
  maxCalls: Number,
  onNotify: Function,
  onDefuse: Function
};

type.argumentDefaults = {
  maxCalls: 2e308,
  onDefuse: emptyFunction
};

type.defineValues({
  maxCalls: getArgProp(0),
  calls: function() {
    if (this.maxCalls !== 2e308) {
      return 0;
    }
  },
  notify: function() {
    return this._getNotifyImpl();
  },
  _stopped: false,
  _onNotify: getArgProp(1),
  _onDefuse: getArgProp(2)
});

isDev && type.defineValues({
  _traceInit: function() {
    return Tracer("Listener()");
  }
});

type.definePrototype({
  isListening: {
    get: function() {
      return this._stopped === false;
    }
  }
});

type.defineMethods({
  start: function() {
    if (!this._stopped) {
      return;
    }
    this._stopped = false;
    this.notify = this._getNotifyImpl();
  },
  stop: function() {
    if (this._stopped) {
      return;
    }
    this._stopped = true;
    this.notify = emptyFunction;
  },
  defuse: function() {
    this._stopped = true;
    this.start = emptyFunction;
    this.notify = emptyFunction;
    this.stop = emptyFunction;
    this.defuse = emptyFunction;
    this._onDefuse(this);
    this._onDefuse = null;
  },
  _getNotifyImpl: function() {
    if (this.maxCalls === 2e308) {
      return this._unlimitedImpl;
    }
    return this._limitedImpl;
  },
  _unlimitedImpl: function(context, args) {
    this._onNotify.apply(context, args);
  },
  _limitedImpl: function(context, args) {
    this.calls += 1;
    this._onNotify.apply(context, args);
    if (this.calls === this.maxCalls) {
      this.defuse();
    }
  }
});

module.exports = type.build();

//# sourceMappingURL=../../map/src/Listener.map
