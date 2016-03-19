
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
    return yes if @_calls < @maxCalls
    @_defuse()
    return no

  stop: ->
    @_defuse()
    @_onStop()
    return

  _defuse: ->
    @_prevent = @notify = @stop = emptyFunction
    return
