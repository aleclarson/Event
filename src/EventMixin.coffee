
{frozen} = require "Property"

spliceArray = require "spliceArray"
Type = require "Type"

Event = require "./Event"

module.exports = (type, eventTypes) ->

  unless type._hasEvents
    frozen.define type, "_hasEvents", {value: yes}
    kind = type._kind
    unless kind and kind::__hasEvents
      mixin.apply type

  type.initInstance ->
    events = @__events
    for eventName, argTypes of eventTypes
      continue if events[eventName]
      options = {argTypes} if argTypes
      events[eventName] = Event options
    return

mixin = Type.Mixin()

mixin.defineValues ->

  __events: Object.create null

mixin.definePrototype

  __hasEvents: yes

mixin.defineMethods

  emit: (eventName) ->
    event = @__events[eventName]
    if event is undefined
      throw Error "Event does not exist: '#{eventName}'"
    event.applyEmit spliceArray arguments, 1

  on: (eventName, callback) ->
    event = @__events[eventName]
    if event is undefined
      throw Error "Event does not exist: '#{eventName}'"
    return event callback

  once: (eventName, callback) ->
    event = @__events[eventName]
    if event is undefined
      throw Error "Event does not exist: '#{eventName}'"
    return event 1, callback
