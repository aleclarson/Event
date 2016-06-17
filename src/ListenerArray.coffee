
emptyFunction = require "emptyFunction"
assertType = require "assertType"
getArgProp = require "getArgProp"
immediate = require "immediate"
assert = require "assert"
Type = require "Type"

Listener = require "./Listener"

type = Type "ListenerArray"

type.defineOptions

  onUpdate:
    type: Function
    default: emptyFunction

type.defineValues

  _value: null

  _length: 0

  _onUpdate: getArgProp "onUpdate"

  _isNotifying: no

  _queue: -> []

  _detached: -> []

type.exposeGetters [
  "length"
  "isNotifying"
]

type.defineMethods

  attach: (listener) ->

    assertType listener, Listener

    if not oldValue = @_value
      @_update listener, 1
      return

    if oldValue.constructor is Listener
      @_update [ oldValue, listener ], 2
      return

    @_update oldValue, oldValue.push listener
    return

  notify: (context, args) ->

    if @_isNotifying or @_queue.length
      @_queue.push [ context, args ]
      return

    oldValue = @_value
    return if not oldValue

    @_isNotifying = yes

    if oldValue.constructor is Listener
      oldValue.notify context, args
    else
      for listener in oldValue
        listener.notify context, args

    @_isNotifying = no

    # Detach any dead listeners immediately after notify ends.
    @_flush()

    # Consume the next queued event, but wait for the event loop to empty.
    immediate => @_next()
    return

  detach: (listener) ->

    assertType listener, Listener

    if @_isNotifying
      @_detached.push listener
      return

    oldValue = @_value
    assert oldValue, "No listeners are attached!"

    if oldValue.constructor is Listener
      assert listener is oldValue, "Listener is not attached to this ListenerArray!"
      @_update null, 0
      return

    index = oldValue.indexOf listener
    assert index >= 0, "Listener is not attached to this ListenerArray!"

    oldValue.splice index, 1
    newCount = oldValue.length

    if newCount is 1 then @_update oldValue[0], 1
    else @_update oldValue, newCount
    return

  reset: ->
    @_update null, 0 if @_length
    return

  _update: (newValue, newLength) ->
    @_value = newValue
    @_length = newLength
    @_onUpdate newValue, newLength
    return

  _flush: ->

    { length } = listeners = @_detached

    if length is 0
      return

    if length is 1
      @detach listeners.pop()
      return

    index = -1
    @detach listeners[index] while ++index < length
    listeners.length = 0
    return

  _next: ->
    queue = @_queue
    return if not queue.length
    [ context, args ] = queue.shift()
    @notify context, args
    return

module.exports = type.build()
