
{frozen} = require "Property"

assertType = require "assertType"
isType = require "isType"
isDev = require "isDev"
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
    sync: Boolean
    async: Boolean
    argTypes: Object

type.defineFunction (maxCalls, callback) ->
  Event.Listener maxCalls, callback
    .attach this

type.defineFrozenValues (_, options) ->

  {argTypes} = options

  emit: ->
    isDev and validateArgs arguments, argTypes
    listeners.notify this, arguments

  _listeners: listeners = ListenerArray
    async: options.async ? not options.sync

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

  sync: ->
    args = arguments
    if isType args[0], Object
    then options = args[0]
    else options = args[1] ? {}
    options.async = no
    Event.apply args

  async: ->
    args = arguments
    if isType args[0], Object
    then options = args[0]
    else options = args[1] ? {}
    options.async = yes
    Event.apply args

  didAttach: get: ->

    frozen.define this, "didAttach",
      value: event = Event {async: no}

    frozen.define event, "_onAttach",
      value: (listener) ->
        @_listeners.attach listener
        return

    return event

module.exports = Event = type.build()

#
# Helpers
#

validateArgs = (args, argTypes) ->
  return unless argTypes
  argNames = Object.keys argTypes
  for name, index in argNames
    assertType args[index], argTypes[name], name
  return
