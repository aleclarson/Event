
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

  # Any listeners that must be detached (once the queue is empty)
  _detached: []

  # Pairs of context & args that will be sent to every listener
  _queue: [] if options.async

  _next: bind.method(this, "_next") if options.async

type.defineGetters

  length: -> @_length

  isNotifying: -> @_isNotifying

type.defineMethods

  attach: (listener) ->

    assertType listener, Listener

    if not oldValue = @_value
      @_update listener, 1
      return

    if oldValue.constructor is Listener
      @_update [oldValue, listener], 2
      return

    @_update oldValue, oldValue.push listener
    return

  notify: (context, args) ->

    queue = @_queue
    if queue and (@_isNotifying or queue.length)
      queue.push [context, args]
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
    if queue
    then immediate @_next
    else @_next()
    return

  detach: (listener) ->

    assertType listener, Listener

    if @_isNotifying
      @_detached.push listener
      return

    oldValue = @_value
    if not oldValue
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

  _next: ->
    queue = @_queue
    return unless queue and queue.length
    [context, args] = queue.shift()
    @notify context, args
    return

module.exports = type.build()
