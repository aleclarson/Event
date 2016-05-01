
{ isType } = require "type-utils"

emptyFunction = require "emptyFunction"
Tracer = require "tracer"
guard = require "guard"
Type = require "Type"

type = Type "Listener"

type.optionTypes =
  onEvent: Function
  onStop: Function
  maxCalls: Number

type.optionDefaults =
  onStop: emptyFunction
  maxCalls: Infinity

type.createArguments (args) ->
  args[0] = { onEvent: args[0] } if isType args[0], Function
  return args

type.defineFrozenValues

  maxCalls: (options) -> options.maxCalls

  _onEvent: (options) -> options.onEvent

  _onStop: (options) -> options.onStop

type.defineValues

  _onDefuse: -> emptyFunction

  _traceInit: -> Tracer "Listener()" if isDev

type.initInstance ->

  if @maxCalls is Infinity
    @notify = @_notifyUnlimited
    return

  @notify = @_notifyLimited
  @calls = 0

type.defineMethods

  stop: ->
    @_defuse()
    @_onStop this
    return

  _notifyUnlimited: (scope, args) ->
    guard => @_onEvent.apply scope, args
    .fail (error) => throwFailure error, { scope, args, listener: this }
    return

  _notifyLimited: (scope, args) ->
    @_calls += 1
    guard => @_onEvent.apply scope, args
    .fail (error) => throwFailure error, { scope, args, listener: this }
    @stop() if @_calls is @maxCalls
    return

  _defuse: ->
    @notify = emptyFunction.thatReturnsFalse
    @_defuse = @stop = emptyFunction
    @_onDefuse()
    return

module.exports = type.build()
