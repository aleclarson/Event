
{ Void
  isType
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

    else if isType options, Function
      options = { onEvent: options }

    [ options ]

  optionTypes:
    onEvent: [ Function, Void ]

  customValues:

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

  initValues: ->

    _listeners: null

  init: (options) ->

    if options.onEvent?
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
    listeners = @_listeners
    return unless listeners
    if isType listeners, Listener
      listeners._defuse()
    else
      for listener in listeners
        listener._defuse()
    @_listeners = null
    return

  _attachListener: (listener) ->
    assertType listener, Listener
    @_listeners = @_retainListener listener, @_listeners
    @_onListen listener
    return listener

  _retainListener: (listener, oldValue) ->
    return listener unless oldValue
    return [ oldValue, listener ] if isType oldValue, Listener
    oldValue.push listener
    oldValue

  # This broadcasts that a Listener has been attached to an Event.
  _onListen: (listener) -> didListen.get().emit this, listener

  _notifyListeners: (scope, args) ->
    listeners = @_listeners
    return unless listeners
    if isType listeners, Listener
      return if listeners.notify scope, args
      @_listeners = null
    else
      listeners = listeners.filter (listener) ->
        listener.notify scope, args
      if listeners.length is 0
        @_listeners = null
      else if listeners.length is 1
        @_listeners = listeners[0]
      else
        @_listeners = listeners
    return

  _detachListener: (listener) ->
    listeners = @_listeners
    if isType listeners, Listener
      return if listener isnt listeners
      @_listeners = null
    else
      index = listeners.indexOf listener
      return if index < 0
      listeners.splice index, 1
      return if listeners.length > 1
      @_listeners = listeners[0]
    return
