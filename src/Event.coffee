
require "isDev"

emptyFunction = require "emptyFunction"
getArgProp = require "getArgProp"
Tracer = require "tracer"
assert = require "assert"
Type = require "Type"

type = Type "Event", (onEmit) ->
  @_attachListener Listener {
    onEmit
    onStop: @_detachListener
  }

type.optionTypes =
  onEmit: Function.Maybe
  onSetListeners: Function.Maybe
  maxRecursion: Number

type.optionDefaults =
  maxRecursion: 0

type.createArguments (args) ->

  if args[0] instanceof Function
    args[0] = { onEmit: args[0] }

  return args

type.defineProperties

  listenerCount: get: ->
    @_listenerCount

  emit: get: ->
    return @_boundEmit if @_boundEmit
    self = this
    return @_boundEmit = ->
      self._emit.call this, arguments, self

  emitArgs: get: ->
    return @_boundEmitArgs if @_boundEmitArgs
    self = this
    return @_boundEmitArgs = (args) ->
      self._emit.call this, args, self

  listenable: get: ->
    return @_listenable if @_listenable
    self = (options) => this options
    self.once = (options) => @once options
    return @_listenable = self

type.defineValues

  _isNotifying: no

  _listenerCount: 0

  _recursionCount: 0

  _maxRecursion: getArgProp "maxRecursion"

  _detachQueue: []

  _listeners: null

  _onSetListeners: getArgProp "onSetListeners"

  _boundEmit: null

  _boundEmitArgs: null

  _listenable: null

if isDev then type.defineValues

  _traceInit: -> Tracer "Event()"

type.initInstance (options) ->

  if options.onEmit
    this options.onEmit

type.bindMethods [
  "_detachListener"
]

type.defineMethods

  once: (onEmit) ->
    @_attachListener Listener {
      onEmit
      maxCalls: 1
      onStop: @_detachListener
    }

  many: (maxCalls, onEmit) ->
    @_attachListener Listener {
      onEmit
      maxCalls
      onStop: @_detachListener
    }

  reset: ->

    oldValue = @_listeners

    return unless oldValue

    if oldValue.constructor is Listener
      oldValue._defuse()

    else
      for listener in oldValue
        listener._defuse()

    @_setListeners null, 0

    return

  _attachListener: (listener) ->

    oldValue = @_listeners

    unless oldValue
      @_setListeners listener, 1

    else if oldValue.constructor is Listener
      @_setListeners [ oldValue, listener ], 2

    else
      oldValue.push listener
      @_setListeners oldValue, oldValue.length

    @_didListen listener

    return listener

  _emit: (args, event) ->
    context = if this is event then null else this
    event._notifyListeners context, args

  _didListen: (listener) ->
    didListen.emit listener, this

  _notifyListeners: (context, args) ->

    oldValue = @_listeners

    return unless oldValue

    if wasNotifying = @_isNotifying
      @_recursionCount += 1
      assert @_recursionCount <= @_maxRecursion,
        reason: "Event is stuck in infinite recursion!"

    else
      @_isNotifying = yes

    if oldValue.constructor is Listener
      oldValue.notify context, args

    else
      listener.notify context, args for listener in oldValue

    unless wasNotifying
      @_isNotifying = no
      @_recursionCount = 0

    @_detachListeners @_detachQueue

  _detachListener: (listener) ->

    if @_isNotifying
      @_detachQueue.push listener
      return

    assert @_listeners, "No listeners are attached!"

    oldValue = @_listeners

    if oldValue.constructor is Listener
      assert listener is oldValue
      @_setListeners null, 0

    else
      index = oldValue.indexOf listener
      assert index >= 0

      oldValue.splice index, 1
      newCount = oldValue.length

      if newCount is 1 then @_setListeners oldValue[0], 1
      else @_setListeners oldValue, newCount

    return

  _detachListeners: (listeners) ->
    count = listeners.length
    return if count is 0
    if count is 1 then @_detachListener listeners[0]
    else @_detachListener listener for listener in listeners
    listeners.length = 0

  _setListeners: (newValue, newCount) ->

    assert newCount isnt @_listenerCount

    @_listeners = newValue if newValue isnt @_listeners

    @_listenerCount = newCount

    return unless @_onSetListeners

    @_onSetListeners newValue, newCount

type.defineStatics

  Listener: Listener = require "./Listener"

  didListen: get: ->
    didListen.listenable

module.exports = Event = type.build()

# Emits whenever a Listener is attached to an Event.
didListen = Event()

# Prevent 'didListen' from triggering itself.
didListen._didListen = emptyFunction
