
{ Void
  isType
  assert
  assertType } = require "type-utils"

Immutable = require "immutable"
Factory = require "factory"

module.exports = Factory "Event",

  initArguments: (options) ->

    assertType options, [ Object, Function, Void ]

    unless options?
      options = {}

    else if isType options, Function
      options = { onEmit: options }

    [ options ]

  func: (listener, callCount) ->
    @_addListener listener, callCount

  customValues:

    emit: lazy: ->
      self = this
      return (args...) ->
        context = this
        callsRemaining = self._callsRemaining
        indexesRemoved = 0
        self.listeners = self.listeners.filter (listener, index) ->
          listener.apply context, args
          index -= indexesRemoved
          calls = callsRemaining[index] - 1
          if calls > 0
            callsRemaining[index] = calls
            return yes
          callsRemaining.splice index, 1
          indexesRemoved += 1
          return no
        self._indexesRemoved = indexesRemoved
        return

    emitArgs: lazy: ->
      { emit } = this
      return (args) ->
        emit.apply this, args

    listenable: lazy: ->
      self = @_addListener.bind this
      self.once = @once.bind this
      self

  initValues: ->
    _callsRemaining: []
    _indexesRemoved: 0

  initReactiveValues: ->
    listeners: Immutable.List()

  init: (options) ->
    @_addListener options.onEmit if options.onEmit?

  once: (listener) ->
    @_addListener listener, 1

  _addListener: (listener, callCount = Infinity) ->
    assertType listener, Function
    assert not listener.stop, "Listener already active!"
    listener.stop = @_removeListener.bind this, listener
    @listeners = @listeners.push listener
    @_callsRemaining.push callCount
    listener

  _removeListener: (listener) ->
    listener.stop = null
    index = @listeners.indexOf listener
    @listeners = @listeners.splice index, 1
    @_callsRemaining.splice index, 1
    return
