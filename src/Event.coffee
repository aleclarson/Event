
require "isDev"

{ isType, assert, assertType } = require "type-utils"
{ throwFailure } = require "failure"

emptyFunction = require "emptyFunction"
LazyVar = require "lazy-var"
Tracer = require "tracer"
guard = require "guard"
Type = require "Type"

type = Type "Event", (onEvent) ->
  @_attachListener Listener {
    onEvent
    onStop: @_detachListener
  }

type.optionTypes =
  onEvent: Function.Maybe
  onSetListeners: Function.Maybe
  maxRecursion: Number

type.optionDefaults =
  maxRecursion: 0

type.createArguments (args) ->

  if isType args[0], Function
    args[0] = { onEvent: args[0] }

  return args

type.defineProperties

  listenerCount: get: ->
    @_listenerCount

  emit: lazy: ->
    self = this
    return ->
      traceEmit = Tracer "Event::emit()" if isDev
      scope = if self is this then null else this
      args = arguments
      guard => self._notifyListeners scope, args
      .fail (error) => throwFailure error, { event: self, stack: [ traceEmit(), @_traceInit() ] }

  emitArgs: lazy: ->
    self = this
    return (args) ->
      traceEmit = Tracer "Event::emitArgs()" if isDev
      scope = if self is this then null else this
      guard => self._notifyListeners scope, args
      .fail (error) => throwFailure error,
        stack: [ traceEmit(), @_traceInit() ]
        event: self

  listenable: lazy: ->
    self = (options) => this options
    self.once = (options) => @once options
    self

type.defineValues

  _isNotifying: no

  _recursionCount: 0

  _maxRecursion: (options) -> options.maxRecursion

  _detachQueue: []

  _listeners: null

  _onSetListeners: (options) -> options.onSetListeners

if isDev
  type.defineValues
    _traceInit: -> Tracer "Event()"

type.defineReactiveValues

  _listenerCount: 0

type.initInstance (options) ->

  if options.onEvent
    this options.onEvent

type.bindMethods [
  "_detachListener"
]

type.defineMethods

  once: (onEvent) ->
    @_attachListener Listener {
      onEvent
      maxCalls: 1
      onStop: @_detachListener
    }

  many: (maxCalls, onEvent) ->
    @_attachListener Listener {
      onEvent
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

    assertType listener, Listener

    oldValue = @_listeners

    unless oldValue
      @_setListeners listener, 1

    else if oldValue.constructor is Listener
      @_setListeners [ oldValue, listener ], 2

    else
      oldValue.push listener
      @_setListeners oldValue, oldValue.length

    @_onListen listener

    return listener

  # This broadcasts that a Listener has been attached to an Event.
  _onListen: (listener) ->
    Event._didListen.get().emit this, listener

  _notifyListeners: (scope, args) ->

    oldValue = @_listeners

    return unless oldValue

    if wasNotifying = @_isNotifying
      @_recursionCount += 1
      assert @_recursionCount <= @_maxRecursion,
        reason: "Event is stuck in infinite recursion!"

    else
      @_isNotifying = yes

    if oldValue.constructor is Listener
      oldValue.notify scope, args

    else
      listener.notify scope, args for listener in oldValue

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
    @_didListen.get().listenable

  _didListen: LazyVar ->
    event = Event()
    event._onListen = emptyFunction
    event

module.exports = Event = type.build()
