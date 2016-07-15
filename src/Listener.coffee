
emptyFunction = require "emptyFunction"
fromArgs = require "fromArgs"
getProto = require "getProto"
Tracer = require "tracer"
Type = require "Type"

type = Type "Listener"

type.initArguments (args) ->
  if args[0] instanceof Function
    args[1] = args[0]
    args[0] = undefined

type.argumentTypes =
  maxCalls: Number
  onNotify: Function

type.argumentDefaults =
  maxCalls: Infinity

type.trace()

type.defineValues

  calls: (maxCalls) -> 0 if maxCalls isnt Infinity

  maxCalls: fromArgs 0

  _event: null

  _impl: -> impls.detached

  _notify: -> emptyFunction

  _onNotify: fromArgs 1

type.definePrototype

  isListening: get: ->
    @_notify isnt emptyFunction

  notify: get: ->
    @_notify

type.defineMethods

  attach: (event) ->
    @_impl.attach.call this, event

  detach: ->
    @_impl.detach.call this

  start: ->
    @_impl.start.call this

  stop: ->
    @_impl.stop.call this

  _attach: (event) ->
    @_impl = impls.stopped
    @_event = event
    @_event._onAttach this
    return this

  _detach: ->
    @_impl = impls.detached
    @_notify = emptyFunction
    @_event._onDetach this
    @_event = null
    return

  _start: ->
    @_impl = impls.started
    @_notify =
      if @maxCalls is Infinity then @_notifyUnlimited
      else @_notifyLimited
    return this

  _stop: ->
    @_impl = impls.stopped
    @_notify = emptyFunction
    return

  _notifyUnlimited: (context, args) ->
    @_onNotify.apply context, args
    return

  _notifyLimited: (context, args) ->
    @calls += 1
    @_onNotify.apply context, args
    @detach() if @calls is @maxCalls
    return

module.exports = Listener = type.build()

impls =

  detached:
    attach: Listener::_attach
    detach: emptyFunction
    start: emptyFunction
    stop: emptyFunction

  stopped:
    attach: emptyFunction.thatReturnsThis
    detach: Listener::_detach
    start: Listener::_start
    stop: emptyFunction

  started:
    attach: emptyFunction.thatReturnsThis
    detach: Listener::_detach
    start: emptyFunction
    stop: Listener::_stop
