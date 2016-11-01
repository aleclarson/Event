
{frozen} = require "Property"

assertType = require "assertType"
isDev = require "isDev"
Null = require "Null"
sync = require "sync"

Event = require "./Event"

module.exports = (type, config) ->

  # Try to create events immediately upon creation.
  type._phases.init.unshift ->
    events = @__events or Object.create null

    sync.each config, (argTypes, key) =>
      assertType argTypes, Object.or Null

      event = Event()
      events[key] = ->

        if isDev and argTypes
          validateArgs arguments, argTypes

        event.emit.apply null, arguments
        return

      frozen.define this, key, {value: event.listenable}
      return

    if not @__events
      frozen.define this, "__events", {value: events}
    return

validateArgs = (args, argTypes) ->
  argNames = Object.keys argTypes
  for name, index in argNames
    assertType args[index], argTypes[name], name
  return
