var Factory, Immutable, assertType, isType, ref,
  slice = [].slice;

ref = require("type-utils"), isType = ref.isType, assertType = ref.assertType;

Immutable = require("immutable");

Factory = require("factory");

module.exports = Factory("Event", {
  initArguments: function(options) {
    assertType(options, [Object, Function, Void]);
    if (options == null) {
      options = {};
    } else if (isType(options, Function)) {
      options = {
        didSet: options
      };
    }
    return [options];
  },
  func: function(listener) {
    assertType(listener, Function);
    this._callCounts.push(null);
    this.listeners = this.listeners.push(listener);
    return listener;
  },
  initFrozenValues: function() {
    var self;
    self = this;
    return {
      emit: function() {
        var args, callCounts, context;
        args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        context = this;
        callCounts = self._callCounts;
        self.listeners = self.listeners.filter(function(listener, index) {
          var callCount;
          listener.apply(context, args);
          callCount = callCounts[index];
          if ((callCount === null) || (callCount > 1)) {
            return true;
          }
          callCounts[index] = callCount - 1;
          return false;
        });
      }
    };
  },
  initValues: function() {
    return {
      _callCounts: []
    };
  },
  initReactiveValues: function() {
    return {
      listeners: Immutable.List()
    };
  },
  init: function(options) {
    if (options.didSet != null) {
      return this(options.didSet);
    }
  },
  once: function(listener) {
    assertType(listener, Function);
    this._callCounts.push(1);
    this.listeners = this.listeners.push(listener);
    return listener;
  },
  remove: function(listener) {
    var index;
    assertType(listener, Function);
    index = this.listeners.indexOf(listener);
    if (index < 0) {
      return false;
    }
    this._callCounts.splice(index, 1);
    this.listeners = this.listeners.splice(index, 1);
    return true;
  }
});

//# sourceMappingURL=../../map/src/Event.map
