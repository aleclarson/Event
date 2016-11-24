
emptyFunction = require "emptyFunction"
assertType = require "assertType"
immediate = require "immediate"
Type = require "Type"
bind = require "bind"

Listener = require "./Listener"

type = Type "ListenerArray"

type.defineOptions
  async: Boolean.withDefault yes
  onUpdate: Function.withDefault emptyFunction

type.defineValues (options) ->

  _onUpdate: options.onUpdate

  # Can equal null, a single listener, or an array of listeners
  _value: null

  # The number of listeners
  _length: 0

  # Are the listeners in the middle of being notified?
  _isNotifying: no

  # The listeners that need detaching
  _detached: []

  # Pairs of context & args that will be sent to every listener
  _queue: [] if options.async

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

  notify: (context, args) ->

    # Don't notify (or push to queue) if no listeners are attached.
    return unless @_value

    # Perform synchronous emits.
    unless @_queue
      @_isNotifying = yes
      @_notify context, args
      @_isNotifying = no
      @_flush()
      return

    # Push to queue if async emit is active.
    if @_isNotifying or @_queue.length
      @_queue.push [context, args]
      return

    # Emit immediately after the JS event loop ticks.
    @_notifyAsync context, args
    return

  detach: (listener) ->

    assertType listener, Listener

    if @_isNotifying
      @_detached.push listener
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
    @_onUpdate newValue, newLength
    return

  _notify: (context, args) ->
    if @_length is 1
    then @_value.notify context, args
    else @_value.forEach (listener) ->
      listener.notify context, args

  _notifyAsync: (context, args) ->
    @_isNotifying = yes
    immediate =>
      @_notify context, args
      @_isNotifying = no
      @_flush()
      if next = @_queue.shift()
        @_notifyAsync next[0], next[1]
      return
    return

  # Flushes the queue of listeners that need detaching.
  _flush: ->

    {length} = listeners = @_detached

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
