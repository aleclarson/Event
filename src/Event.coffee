
require "isDev"

emptyFunction = require "emptyFunction"
getArgProp = require "getArgProp"
Tracer = require "tracer"
assert = require "assert"
Type = require "Type"

type = Type "Event", (onNotify) ->
  @_createListener Infinity, onNotify

type.optionTypes =
  onNotify: Function.Maybe
  onSetListeners: Function
  maxRecursion: Number

type.optionDefaults =
  onSetListeners: emptyFunction
  maxRecursion: 0

type.createArguments (args) ->

  if args[0] instanceof Function
    args[0] = { onNotify: args[0] }

  return args

type.defineProperties

  listenerCount: get: ->
    @_listenerCount

  emit: get: ->
    @_boundEmit or @_boundEmit = @_bindEmit()

  emitArgs: get: ->
    @_boundEmitArgs or @_boundEmitArgs = @_bindEmitArgs()

  listenable: get: ->
    @_listenable or @_listenable = @_createListenable()

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

isDev and type.defineValues

  _traceInit: -> Tracer "Event()"

type.initInstance (options) ->

  if options.onNotify
    @_createListener Infinity, options.onNotify

type.bindMethods [
  "_detachListener"
]

type.defineMethods

  once: (onNotify) ->
    @_createListener 1, onNotify

  many: (maxCalls, onNotify) ->
    @_createListener maxCalls, onNotify

  reset: ->
    return if @_listenerCount is 0
    @_setListeners null, 0
    return

  _bindEmit: ->
    event = this
    return ->
      event._notifyListeners this, arguments
      return

  _bindEmitArgs: ->
    event = this
    return (args) ->
      event._notifyListeners this, args
      return

  _createListenable: ->
    event = this
    self = (onNotify) -> event._createListener Infinity, onNotify
    self.once = (onNotify) -> event._createListener 1, onNotify
    return self

  _createListener: (maxCalls, onNotify) ->
    listener = Listener maxCalls, onNotify, @_detachListener
    @_attachListener listener
    return listener

  _attachListener: (listener) ->

    oldValue = @_listeners

    if not oldValue
      @_setListeners listener, 1

    else if oldValue.constructor is Listener
      @_setListeners [ oldValue, listener ], 2

    else
      oldValue.push listener
      @_setListeners oldValue, oldValue.length

    @_didListen listener
    return

  _didListen: (listener) ->
    didListen.emit listener, this
    return

  _notifyListeners: (context, args) ->

    oldValue = @_listeners

    return if not oldValue

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

    if not wasNotifying
      @_isNotifying = no
      @_recursionCount = 0

    @_detachListeners @_detachQueue
    return

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
    return

  _setListeners: (newValue, newCount) ->
    assert newCount isnt @_listenerCount
    @_listeners = newValue
    @_listenerCount = newCount
    @_onSetListeners newValue, newCount
    return

type.defineStatics

  Listener: Listener = require "./Listener"

  didListen: get: ->
    didListen.listenable

module.exports = Event = type.build()

# Emits whenever a Listener is attached to an Event.
didListen = Event()

# Prevent 'didListen' from triggering itself.
didListen._didListen = emptyFunction
