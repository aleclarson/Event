
require "isDev"

emptyFunction = require "emptyFunction"
getArgProp = require "getArgProp"
Tracer = require "tracer"
Type = require "Type"

type = Type "Listener"

type.optionTypes =
  onEmit: Function
  onStop: Function
  maxCalls: Number

type.optionDefaults =
  onStop: emptyFunction
  maxCalls: Infinity

type.initArguments (args) ->

  if args[0] instanceof Function
    args[0] = onEmit: args[0]

type.defineFrozenValues

  maxCalls: getArgProp "maxCalls"

type.defineValues

  start: -> emptyFunction

  stop: -> @_stopImpl

  notify: -> @_getNotifyImpl()

  calls: -> 0 if @maxCalls isnt Infinity

  _defuse: -> @_defuseImpl

  _onEmit: getArgProp "onEmit"

  _onStop: getArgProp "onStop"

  _onDefuse: -> emptyFunction

if isDev
  type.defineValues
    _traceInit: -> Tracer "Listener()"

type.defineMethods

  _getNotifyImpl: ->
    return @_unlimitedImpl if @maxCalls is Infinity
    return @_limitedImpl

  _unlimitedImpl: (context, args) ->
    @_onEmit.apply context, args
    return

  _limitedImpl: (context, args) ->
    @calls += 1
    @_onEmit.apply context, args
    @stop() if @calls is @maxCalls
    return

  _startImpl: ->
    @start = emptyFunction
    @notify = @_getNotifyImpl()
    @stop = @_stopImpl
    @_defuse = @_defuseImpl
    return

  _stopImpl: ->
    @_defuse()
    @_onStop this
    return

  _defuseImpl: ->
    @start = @_startImpl
    @notify = emptyFunction
    @stop = emptyFunction
    @_defuse = emptyFunction
    @_onDefuse()
    return

module.exports = type.build()
