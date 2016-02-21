
{ isType, assertType } = require "type-utils"

Immutable = require "immutable"
Factory = require "factory"

module.exports = Factory "Event",

  initArguments: (options) ->

    assertType options, [ Object, Function, Void ]

    unless options?
      options = {}

    else if isType options, Function
      options = { didSet: options }

    [ options ]

  func: (listener) ->
    assertType listener, Function
    @_callCounts.push null
    @listeners = @listeners.push listener
    listener

  initFrozenValues: ->

    self = this

    emit: (args...) ->
      context = this
      callCounts = self._callCounts
      self.listeners = self.listeners.filter (listener, index) ->
        listener.apply context, args
        callCount = callCounts[index]
        return yes if (callCount is null) or (callCount > 1)
        callCounts[index] = callCount - 1
        return no
      return

  initValues: ->
    _callCounts: []

  initReactiveValues: ->
    listeners: Immutable.List()

  init: (options) ->

    if options.didSet?
      @ options.didSet

  once: (listener) ->
    assertType listener, Function
    @_callCounts.push 1
    @listeners = @listeners.push listener
    listener

  remove: (listener) ->
    assertType listener, Function
    index = @listeners.indexOf listener
    return no if index < 0
    @_callCounts.splice index, 1
    @listeners = @listeners.splice index, 1
    return yes
