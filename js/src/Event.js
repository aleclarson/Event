var Factory, Immutable, Void, assert, assertType, isType, ref,
  slice = [].slice;

ref = require("type-utils"), Void = ref.Void, isType = ref.isType, assert = ref.assert, assertType = ref.assertType;

Immutable = require("immutable");

Factory = require("factory");

module.exports = Factory("Event", {
  initArguments: function(options) {
    assertType(options, [Object, Function, Void]);
    if (options == null) {
      options = {};
    } else if (isType(options, Function)) {
      options = {
        onEmit: options
      };
    }
    return [options];
  },
  func: function(listener, callCount) {
    return this._addListener(listener, callCount);
  },
  customValues: {
    emit: {
      lazy: function() {
        var self;
        self = this;
        return function() {
          var args, callsRemaining, context, indexesRemoved;
          args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
          context = this;
          callsRemaining = self._callsRemaining;
          indexesRemoved = 0;
          self.listeners = self.listeners.filter(function(listener, index) {
            var calls;
            listener.apply(context, args);
            index -= indexesRemoved;
            calls = callsRemaining[index] - 1;
            if (calls > 0) {
              callsRemaining[index] = calls;
              return true;
            }
            callsRemaining.splice(index, 1);
            indexesRemoved += 1;
            return false;
          });
          self._indexesRemoved = indexesRemoved;
        };
      }
    },
    emitArgs: {
      lazy: function() {
        var emit;
        emit = this.emit;
        return function(args) {
          return emit.apply(this, args);
        };
      }
    },
    listenable: {
      lazy: function() {
        var self;
        self = this._addListener.bind(this);
        self.once = this.once.bind(this);
        return self;
      }
    }
  },
  initValues: function() {
    return {
      _callsRemaining: [],
      _indexesRemoved: 0
    };
  },
  initReactiveValues: function() {
    return {
      listeners: Immutable.List()
    };
  },
  init: function(options) {
    if (options.onEmit != null) {
      return this._addListener(options.onEmit);
    }
  },
  once: function(listener) {
    return this._addListener(listener, 1);
  },
  _addListener: function(listener, callCount) {
    if (callCount == null) {
      callCount = Infinity;
    }
    assertType(listener, Function);
    assert(!listener.stop, "Listener already active!");
    listener.stop = this._removeListener.bind(this, listener);
    this.listeners = this.listeners.push(listener);
    this._callsRemaining.push(callCount);
    return listener;
  },
  _removeListener: function(listener) {
    var index;
    listener.stop = null;
    index = this.listeners.indexOf(listener);
    this.listeners = this.listeners.splice(index, 1);
    this._callsRemaining.splice(index, 1);
  }
});

//# sourceMappingURL=../../map/src/Event.map
