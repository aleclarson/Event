
require "isDev"

emptyFunction = require "emptyFunction"
getArgProp = require "getArgProp"
Tracer = require "tracer"
Type = require "Type"

type = Type "EventListener"

type.initArguments (args) ->
  if args[0] instanceof Function
    args[1] = args[0]
    args[0] = undefined

type.argumentTypes =
  maxCalls: Number
  onNotify: Function
  onDefuse: Function

type.argumentDefaults =
  maxCalls: Infinity
  onDefuse: emptyFunction

type.defineValues

  maxCalls: getArgProp 0

  calls: -> 0 if @maxCalls isnt Infinity

  notify: -> @_getNotifyImpl()

  _stopped: no

  _onNotify: getArgProp 1

  _onDefuse: getArgProp 2

isDev and type.defineValues

  _traceInit: -> Tracer "Listener()"

type.definePrototype

  isListening: get: ->
    @_stopped is no

type.defineMethods

  start: ->
    return if not @_stopped
    @_stopped = no
    @notify = @_getNotifyImpl()
    return

  stop: ->
    return if @_stopped
    @_stopped = yes
    @notify = emptyFunction
    return

  defuse: ->
    @_stopped = yes
    @start = emptyFunction
    @notify = emptyFunction
    @stop = emptyFunction
    @defuse = emptyFunction
    @_onDefuse this
    @_onDefuse = null
    return

  _getNotifyImpl: ->
    return @_unlimitedImpl if @maxCalls is Infinity
    return @_limitedImpl

  _unlimitedImpl: (context, args) ->
    @_onNotify.apply context, args
    return

  _limitedImpl: (context, args) ->
    @calls += 1
    @_onNotify.apply context, args
    @defuse() if @calls is @maxCalls
    return

module.exports = type.build()
