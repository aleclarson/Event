var Listener, Tracer, Type, emptyFunction, getArgProp, getProto, impls, type;

emptyFunction = require("emptyFunction");

getArgProp = require("getArgProp");

getProto = require("getProto");

Tracer = require("tracer");

Type = require("Type");

type = Type("Listener");

type.initArguments(function(args) {
  if (args[0] instanceof Function) {
    args[1] = args[0];
    return args[0] = void 0;
  }
});

type.argumentTypes = {
  maxCalls: Number,
  onNotify: Function
};

type.argumentDefaults = {
  maxCalls: 2e308
};

type.trace();

type.defineValues({
  calls: function(maxCalls) {
    if (maxCalls !== 2e308) {
      return 0;
    }
  },
  maxCalls: getArgProp(0),
  _event: null,
  _impl: function() {
    return impls.detached;
  },
  _notify: function() {
    return emptyFunction;
  },
  _onNotify: getArgProp(1)
});

type.definePrototype({
  isListening: {
    get: function() {
      return this._notify !== emptyFunction;
    }
  },
  notify: {
    get: function() {
      return this._notify;
    }
  }
});

type.defineMethods({
  attach: function(event) {
    return this._impl.attach.call(this, event);
  },
  detach: function() {
    return this._impl.detach.call(this);
  },
  start: function() {
    return this._impl.start.call(this);
  },
  stop: function() {
    return this._impl.stop.call(this);
  },
  _attach: function(event) {
    this._impl = impls.stopped;
    this._event = event;
    this._event._onAttach(this);
    return this;
  },
  _detach: function() {
    this._impl = impls.detached;
    this._notify = emptyFunction;
    this._event._onDetach(this);
    this._event = null;
  },
  _start: function() {
    this._impl = impls.started;
    this._notify = this.maxCalls === 2e308 ? this._notifyUnlimited : this._notifyLimited;
    return this;
  },
  _stop: function() {
    this._impl = impls.stopped;
    this._notify = emptyFunction;
  },
  _notifyUnlimited: function(context, args) {
    this._onNotify.apply(context, args);
  },
  _notifyLimited: function(context, args) {
    this.calls += 1;
    this._onNotify.apply(context, args);
    if (this.calls === this.maxCalls) {
      this.detach();
    }
  }
});

module.exports = Listener = type.build();

impls = {
  detached: {
    attach: Listener.prototype._attach,
    detach: emptyFunction,
    start: emptyFunction,
    stop: emptyFunction
  },
  stopped: {
    attach: emptyFunction.thatReturnsThis,
    detach: Listener.prototype._detach,
    start: Listener.prototype._start,
    stop: emptyFunction
  },
  started: {
    attach: emptyFunction.thatReturnsThis,
    detach: Listener.prototype._detach,
    start: emptyFunction,
    stop: Listener.prototype._stop
  }
};

//# sourceMappingURL=map/Listener.map
