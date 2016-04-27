
require "isDev"

{ isType } = require "type-utils"

emptyFunction = require "emptyFunction"
Factory = require "factory"
define = require "define"
Tracer = require "tracer"
guard = require "guard"

module.exports =
Listener = Factory "Listener",

  optionTypes:
    onEvent: Function
    onStop: Function
    maxCalls: Number

  optionDefaults:
    onStop: emptyFunction
    maxCalls: Infinity

  initArguments: (options) ->
    options = { onEvent: options } if isType options, Function
    [ options ]

  customValues:

    calls: get: ->
      @_calls

  initFrozenValues: (options) ->

    maxCalls: options.maxCalls

    _onEvent: options.onEvent

    _onStop: options.onStop

  initValues: (options) ->

    _onDefuse: emptyFunction

    _traceInit: Tracer "Listener()" if isDev

  init: ->

    if @maxCalls is Infinity
      @notify = @_notifyUnlimited

    else
      define this, "_calls", 0
      @notify = @_notifyLimited

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
