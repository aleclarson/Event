
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

  type.createArgs (args) ->
    unless options = args[0]
      args[0] = options = {}
    return args

  if argTypes = config.argTypes
    assertType argTypes, Object
    type.createArgs (args) ->
      args[0].argTypes = argTypes
      return args

  if config.async?
    isAsync = config.async
    type.createArgs (args) ->
      args[0].async = isAsync
      return args

  return type.build()

module.exports = EventType
