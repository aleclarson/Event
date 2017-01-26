
emptyFunction = require "emptyFunction"
assertType = require "assertType"
immediate = require "immediate"
Type = require "Type"

Listener = require "./Listener"

type = Type "ListenerArray"

type.defineArgs
  async: Boolean

type.defineValues (options) ->

  # Can equal null, a single listener, or an array of listeners
  _value: null

  # The number of listeners
  _length: 0

  # Equals true if listeners are being notified
  _isNotifying: no

  # The listeners that need detaching
  _detachQueue: []

  # An arguments queue used for notifying listeners
  _notifyQueue: [] if options.async

type.defineGetters

  length: -> @_length

  isNotifying: -> @_isNotifying

type.defineMethods

  attach: (listener) ->

    assertType listener, Listener

    unless oldValue = @_value
      @_update listener, 1
      return

    if oldValue.constructor is Listener
      @_update [oldValue, listener], 2
      return

    @_update oldValue, oldValue.push listener
    return

  notify: (args) ->

    # Don't notify (or push to queue) if no listeners are attached.
    return unless @_value

    # Perform synchronous emits.
    unless @_notifyQueue
      @_isNotifying = yes
      @_notify args
      @_isNotifying = no
      @_flush()
      return

    # Push to queue if async emit is active.
    if @_isNotifying or @_notifyQueue.length
      @_notifyQueue.push args
      return

    # Emit immediately after the JS event loop ticks.
    @_notifyAsync args
    return

  detach: (listener) ->

    assertType listener, Listener

    if @_isNotifying
      @_detachQueue.push listener
      return

    unless oldValue = @_value
      throw Error "No listeners are attached!"

    if oldValue.constructor is Listener

      if listener isnt oldValue
        throw Error "Listener is not attached to this ListenerArray!"

      @_update null, 0
      return

    index = oldValue.indexOf listener
    if index < 0
      throw Error "Listener is not attached to this ListenerArray!"

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
    return

  _notify: (args) ->
    if @_length is 1
    then @_value.notify args
    else @_value.forEach (listener) ->
      listener.notify args

  _notifyAsync: (args) ->
    @_isNotifying = yes
    immediate this, ->
      @_value and @_notify args
      @_isNotifying = no
      @_flush()
      if next = @_notifyQueue.shift()
        @_notifyAsync next[0], next[1]
      return
    return

  # Flushes the queue of listeners that need detaching.
  _flush: ->

    {length} = listeners = @_detachQueue

    if length is 0
      return

    if length is 1
      @detach listeners.pop()
      return

    index = -1
    @detach listeners[index] while ++index < length
    listeners.length = 0
    return

module.exports = type.build()
