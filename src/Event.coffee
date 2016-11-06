
{frozen} = require "Property"

isType = require "isType"
Type = require "Type"

ListenerArray = require "./ListenerArray"

type = Type "Event"

type.trace()

type.initArgs (args) ->
  if isType args[0], Object
    args[1] = args[0]
    args[0] = undefined
  else
    args[1] ?= {}
  return

type.defineArgs
  callback: Function
  options:
    async: Boolean

type.defineFunction (maxCalls, callback) ->
  Event.Listener maxCalls, callback
    .attach this

type.defineFrozenValues

  emit: (_, options) ->
    listeners = ListenerArray {async: options.async ? yes}
    frozen.define this, "_listeners", {value: listeners}
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
