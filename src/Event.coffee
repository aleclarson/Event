
{ frozen } = require "Property"

Tracer = require "tracer"
Type = require "Type"

ListenerArray = require "./ListenerArray"

type = Type "Event"

type.trace()

type.initArgs (args) ->
  if typeof args[0] is "function"
    args[0] = callback: args[0]
  return

type.defineOptions
  async: Boolean.withDefault yes
  callback: Function

type.defineFunction (maxCalls, callback) ->
  Event.Listener maxCalls, callback
    .attach this

type.defineFrozenValues

  emit: (options) ->
    listeners = ListenerArray {async: options.async}
    frozen.define this, "_listeners", {value: listeners}
    return -> listeners.notify this, arguments

# If a callback was passed, create a Listener
# that listens until this Event is GC'd.
type.initInstance (options) ->
  return if not options.callback
  Event.Listener options.callback
    .attach this
    .start()

type.defineGetters

  listenable: ->
    @_listenable or @_defineListenable()

  listenerCount: ->
    @_listeners.length

  hasListeners: ->
    @_listeners.length > 0

type.defineMethods

  reset: ->
    @_listeners.reset()
    return

  _onAttach: (listener) ->
    @_listeners.attach listener
    Event.didAttach.emit listener, this
    return

  _onDetach: (listener) ->
    @_listeners.detach listener
    return

  _defineListenable: ->

    event = this
    listenable = (maxCalls, callback) ->
      Event.Listener maxCalls, callback
        .attach event

    frozen.define event, "_listenable", {value: listenable}
    return listenable

type.defineStatics

  didAttach: lazy: ->

    event = Event()

    frozen.define event, "_onAttach",
      value: (listener) ->
        @_listeners.attach listener
        return

    return event

module.exports = Event = type.build()
