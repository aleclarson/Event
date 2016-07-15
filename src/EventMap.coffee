
require "isDev"

{ mutable } = require "Property"

assertType = require "assertType"
assert = require "assert"
steal = require "steal"
Type = require "Type"

Event = require "./Event"

type = Type "EventMap", (eventName, maxCalls, onNotify) ->
  listener = Event.Listener maxCalls, onNotify
  mutable.define listener, "_eventName", eventName
  return listener.attach this

type.argumentTypes =
  events: Object

type.defineFrozenValues

  emit: ->
    eventMap = this
    return (eventName, args) ->

      listeners = eventMap._listeners[eventName]
      assert listeners, "Invalid event name!"

      assertType eventName, String, "eventName"
      assert typeof args.length is "number", "'args' must be an array-like object!"

      if isDev and args
        eventMap._validateTypes eventName, args

      listeners.notify this, args
      return

  _listeners: -> Object.create null

  _types: -> Object.create null

type.initInstance (events) ->
  @_addEvents events

type.defineMethods

  _addEvents: (events) ->
    for eventName, config of events
      @_types[eventName] = steal config, "types" if config.types
      @_listeners[eventName] = Event.ListenerArray()
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

  _validateTypes: (event, args) ->
    types = @_types[event]
    return if not types
    index = 0
    for key, type of types
      assertType args[index], type, key
      index += 1
    return

module.exports = type.build()
