
{ frozen } = require "Property"

Tracer = require "tracer"
Type = require "Type"

type = Type "Event"

type.trace()

type.defineArgs
  callback: Function

type.defineFunction (maxCalls, callback) ->
  Event.Listener maxCalls, callback
    .attach this

type.defineFrozenValues

  emit: ->
    listeners = Event.ListenerArray()
    frozen.define this, "_listeners", { value: listeners }
    return -> listeners.notify this, arguments

# If a callback was passed, create a Listener
# that listens until this Event is GC'd.
type.initInstance (callback) ->
  return if not callback
  Event.Listener callback
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

    frozen.define event, "_listenable", { value: listenable }
    return listenable

type.defineStatics

  Map: lazy: ->
    require "./EventMap"

  Listener: lazy: ->
    require "./Listener"

  ListenerArray: lazy: ->
    require "./ListenerArray"

  didAttach: lazy: ->

    event = Event()

    frozen.define event, "_onAttach",
      value: (listener) ->
        @_listeners.attach listener
        return

    return event

module.exports = Event = type.build()
