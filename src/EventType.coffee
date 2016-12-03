
NamedFunction = require "NamedFunction"
assertType = require "assertType"
Type = require "Type"

Event = require "./Event"

EventType = NamedFunction "EventType", (name, config) ->

  if arguments.length is 1
    config = name
    name = undefined

  assertType name, String.Maybe
  assertType config, Object

  type = Type name
  type.inherits Event

  type.initArgs (args) ->
    unless options = args[0]
      args[0] = options = {}
    return

  if argTypes = config.argTypes
    assertType argTypes, Object
    type.initArgs (args) ->
      args[0].argTypes = argTypes
      return

  if config.async? or config.sync?
    isAsync = config.async ? not config.sync
    type.initArgs (args) ->
      args[0].async = isAsync
      return

  return type.build()

module.exports = EventType
