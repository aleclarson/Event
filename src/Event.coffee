
{ frozen } = require "Property"

Tracer = require "tracer"
Type = require "Type"

type = Type "Event", (maxCalls, onNotify) ->
  Event.Listener maxCalls, onNotify
    .attach this

type.argumentTypes =
  onNotify: Function.Maybe

type.trace()

type.defineFrozenValues

  emit: ->
    listeners = Event.ListenerArray()
    frozen.define this, "_listeners", listeners
    return -> listeners.notify this, arguments

# If a callback was passed, create a Listener
# that listens until this Event is GC'd.
type.initInstance (onNotify) ->
  return if not onNotify
  Event.Listener onNotify
    .attach this
    .start()

type.definePrototype

  listenable: get: ->
    @_listenable or @_defineListenable()

  listenerCount: get: ->
    @_listeners.length

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
    listenable = (maxCalls, onNotify) ->
      Event.Listener maxCalls, onNotify
        .attach event

    frozen.define event, "_listenable", listenable
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

    frozen.define event, "_onAttach", (listener) ->
      @_listeners.attach listener
      return

    return event

module.exports = Event = type.build()
