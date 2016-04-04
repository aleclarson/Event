
{ Void
  assert
  assertType } = require "type-utils"

{ throwFailure } = require "failure"

emptyFunction = require "emptyFunction"
LazyVar = require "lazy-var"
Factory = require "factory"

Listener = require "./Listener"

didListen = LazyVar ->
  event = Event()
  event._onListen = emptyFunction
  event

module.exports =
Event = Factory "Event",

  statics: {
    Listener
    didListen: get: ->
      didListen.get().listenable
  }

  initArguments: (options) ->

    assertType options, [ Object, Function, Void ]

    unless options?
      options = {}

    else if options.constructor is Function
      options = { onEvent: options }

    [ options ]

  optionTypes:
    onEvent: Function.Maybe
    onSetListeners: Function.Maybe

  customValues:

    listenerCount: get: ->
      @_listenerCount

    emit: lazy: ->
      self = this
      return ->
        self._notifyListeners this, arguments

    emitArgs: lazy: ->
      self = this
      return (args) ->
        self._notifyListeners this, args

    listenable: lazy: ->
      self = (options) => this options
      self.once = (options) => @once options
      self

  initValues: (options) ->

    _isNotifying: no

    _detachQueue: []

    _listeners: null

    _onSetListeners: options.onSetListeners

  initReactiveValues: ->

    _listenerCount: 0

  init: (options) ->

    if options.onEvent
      this options.onEvent

  boundMethods: [
    "_detachListener"
  ]

  func: (onEvent) ->
    @_attachListener Listener {
      onEvent
      onStop: @_detachListener
    }

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
    didListen.get().emit this, listener

  _notifyListeners: (scope, args) ->

    oldValue = @_listeners

    return unless oldValue

    @_isNotifying = yes

    if oldValue.constructor is Listener
      oldValue.notify scope, args

    else
      listener.notify scope, args for listener in oldValue

    @_isNotifying = no

    @_detachListeners @_detachQueue

  _detachListener: (listener) ->

    if @_isNotifying
      @_detachQueue.push listener
      return

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
