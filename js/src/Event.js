var Event, Tracer, Type, frozen, type;

frozen = require("Property").frozen;

Tracer = require("tracer");

Type = require("Type");

type = Type("Event", function(maxCalls, onNotify) {
  return Event.Listener(maxCalls, onNotify).attach(this);
});

type.argumentTypes = {
  onNotify: Function.Maybe
};

type.trace();

type.defineFrozenValues({
  emit: function() {
    var listeners;
    listeners = Event.ListenerArray();
    frozen.define(this, "_listeners", listeners);
    return function() {
      return listeners.notify(this, arguments);
    };
  }
});

type.initInstance(function(onNotify) {
  if (!onNotify) {
    return;
  }
  return Event.Listener(onNotify).attach(this).start();
});

type.definePrototype({
  listenable: {
    get: function() {
      return this._listenable || this._defineListenable();
    }
  },
  listenerCount: {
    get: function() {
      return this._listeners.length;
    }
  }
});

type.defineMethods({
  reset: function() {
    this._listeners.reset();
  },
  _onAttach: function(listener) {
    this._listeners.attach(listener);
    Event.didAttach.emit(listener, this);
  },
  _onDetach: function(listener) {
    this._listeners.detach(listener);
  },
  _defineListenable: function() {
    var event, listenable;
    event = this;
    listenable = function(maxCalls, onNotify) {
      return Event.Listener(maxCalls, onNotify).attach(event);
    };
    frozen.define(event, "_listenable", listenable);
    return listenable;
  }
});

type.defineStatics({
  Map: {
    lazy: function() {
      return require("./EventMap");
    }
  },
  Listener: {
    lazy: function() {
      return require("./Listener");
    }
  },
  ListenerArray: {
    lazy: function() {
      return require("./ListenerArray");
    }
  },
  didAttach: {
    lazy: function() {
      var event;
      event = Event();
      frozen.define(event, "_onAttach", function(listener) {
        this._listeners.attach(listener);
      });
      return event;
    }
  }
});

module.exports = Event = type.build();

//# sourceMappingURL=../../map/src/Event.map
