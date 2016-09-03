
require "isDev"

{mutable} = require "Property"

assertType = require "assertType"
isType = require "isType"
Type = require "Type"

Event = require "./Event"

type = Type "EventMap"

type.defineArgs
  events: Object.isRequired

type.defineFrozenValues

  emit: ->
    eventMap = this
    return (eventName, args) ->

      assertType eventName, String, "eventName"
      listeners = eventMap._listeners[eventName]

      if isDev
        if not listeners
          throw Error "Event named '#{eventName}' does not exist!"
        eventMap._validateArgs eventName, args

      listeners.notify this, args
      return

  _listeners: -> Object.create null

  _types: -> Object.create null

type.initInstance (events) ->
  @_addEvents events

type.defineFunction (eventName, maxCalls, callback) ->
  listener = Event.Listener maxCalls, callback
  mutable.define listener, "_eventName", {value: eventName}
  return listener.attach this

type.defineMethods

  _addEvents: (events) ->
    types = @_types
    listeners = @_listeners
    for eventName, eventTypes of events

      if isDev and listeners[eventName]
        throw Error "Event named '#{eventName}' already exists!"

      eventTypes and types[eventName] = eventTypes
      listeners[eventName] = Event.ListenerArray()
    return

  _onAttach: (listener) ->

    if isDev and not @_listeners[listener._eventName]
      throw Error "Invalid event name: '#{listener._eventName}'"

    @_listeners[listener._eventName].attach listener
    Event.didAttach.emit listener, this
    return

  _onDetach: (listener) ->
    @_listeners[listener._eventName].detach listener
    listener._eventName = null
    return

isDev and
type.defineMethods

  _validateArgs: (eventName, args) ->
    argTypes = @_types[eventName]
    return if not argTypes

    if isDev and not isType args.length, Number
      throw Error "'args' must be an array-like object!"

    index = 0
    for argName, argType of argTypes
      assertType args[index], argType, argName
      index += 1
    return

module.exports = type.build()
