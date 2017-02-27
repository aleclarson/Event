
emptyFunction = require "emptyFunction"
getProto = require "getProto"
Tracer = require "tracer"
Type = require "Type"

type = Type "Listener"

type.trace()

type.defineArgs ->

  create: (args) ->
    if typeof args[0] is "function"
      args[1] = args[0]
      args[0] = undefined
    return args

  defaults: [Infinity]
  types: [
    Number   # maxCalls
    Function # callback
  ]

type.defineValues (maxCalls, callback) ->

  maxCalls: maxCalls

  calls: 0 if maxCalls isnt Infinity

  _event: null

  _impl: impls.detached

  _notify: emptyFunction

  _callback: callback

  _onDetach: emptyFunction

type.defineGetters

  isListening: -> @_notify isnt emptyFunction

  notify: -> @_notify

type.defineMethods

  attach: (event) ->
    @_impl.attach.call this, event

  detach: ->
    @_impl.detach.call this

  start: ->
    @_impl.start.call this

  stop: ->
    @_impl.stop.call this

  onDetach: (callback) ->

    if @_onDetach is emptyFunction
      @_onDetach = callback
      return

    callbackBefore = @_onDetach
    @_onDetach = ->
      callbackBefore()
      callback()
    return

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
    @_onDetach()
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

  _notifyUnlimited: (args) ->
    @_callback.apply null, args
    return

  _notifyLimited: (args) ->
    @calls += 1
    @_callback.apply null, args
    @detach() if @calls is @maxCalls
    return

module.exports = Listener = type.build()

impls =

  detached:
    attach: Listener::_attach
    detach: emptyFunction
    start: emptyFunction.thatReturnsThis
    stop: emptyFunction

  stopped:
    attach: emptyFunction.thatReturnsThis
    detach: Listener::_detach
    start: Listener::_start
    stop: emptyFunction

  started:
    attach: emptyFunction.thatReturnsThis
    detach: Listener::_detach
    start: emptyFunction.thatReturnsThis
    stop: Listener::_stop
