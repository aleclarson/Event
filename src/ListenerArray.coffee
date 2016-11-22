
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

    unless @_queue
      @_isNotifying = yes
      @_notify context, args
      @_isNotifying = no
      @_flush()
      return

    if @_isNotifying or @_queue.length
      @_queue.push [context, args]
      return

    @_notifyAsync context, args
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

  # Notify all attached listeners synchronously.
  _notify: (context, args) ->

    return unless value = @_value

    if value.constructor is Listener
      value.notify context, args
      return

    for listener in value
      listener.notify context, args
    return

  # Notify all attached listeners (once the JS loop is empty).
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
