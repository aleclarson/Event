
{ isType } = require "type-utils"

emptyFunction = require "emptyFunction"
Factory = require "factory"

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

  initValues: ->

    _calls: 0

  notify: (scope, args) ->
    @_calls += 1
    @_onEvent.apply scope, args
    @stop() if @_calls is @maxCalls
    return

  stop: ->
    @_defuse()
    @_onStop this
    return

  _defuse: ->
    @notify = emptyFunction.thatReturnsFalse
    @_defuse = @stop = emptyFunction
    return
