
require "isDev"

{ mutable } = require "Property"

assertType = require "assertType"
isType = require "isType"
assert = require "assert"
steal = require "steal"
Type = require "Type"

Event = require "./Event"

type = Type "EventMap", (eventName, maxCalls, onNotify) ->
  listener = Event.Listener maxCalls, onNotify
  mutable.define listener, "_eventName", { value: eventName }
  return listener.attach this

type.argumentTypes =
  events: Object

type.defineFrozenValues

  emit: ->
    eventMap = this
    return (eventName, args) ->

      assertType eventName, String, "eventName"
      listeners = eventMap._listeners[eventName]
      assert listeners, "Event named '#{eventName}' does not exist!"

      if isDev and args
        assert isType(args.length, Number), "'args' must be an array-like object!"
        eventMap._validateArgs eventName, args

      listeners.notify this, args
      return

  _listeners: -> Object.create null

  _types: -> Object.create null

type.initInstance (events) ->
  @_addEvents events

type.defineMethods

  _addEvents: (events) ->
    types = @_types
    listeners = @_listeners
    for eventName, eventTypes of events
      assert not listeners[eventName], "Event named '#{eventName}' already exists!"
      eventTypes and types[eventName] = eventTypes
      listeners[eventName] = Event.ListenerArray()
    return

  _onAttach: (listener) ->
    assert @_listeners[listener._eventName], "Invalid event name!"
    @_listeners[listener._eventName].attach listener
    Event.didAttach.emit listener, this
    return

  _onDetach: (listener) ->
    @_listeners[listener._eventName].detach listener
    listener._eventName = null
    return

isDev and type.defineMethods

  _validateArgs: (eventName, args) ->
    return if not argTypes = @_types[eventName]
    index = 0
    for argName, argType of argTypes
      assertType args[index], argType, argName
      index += 1
    return

module.exports = type.build()
