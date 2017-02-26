
{frozen} = require "Property"

assertType = require "assertType"
isType = require "isType"
isDev = require "isDev"
Type = require "Type"
bind = require "bind"

ListenerArray = require "./ListenerArray"

type = Type "Event"

type.trace()

type.defineArgs ->

  create: (args) ->
    if isType args[0], Object
      args[1] = args[0]
      args[0] = undefined
    return args

  required: no
  types: [
    Function
    async: Boolean.Maybe
    argTypes: Object.Maybe
  ]

type.defineFunction (maxCalls, callback) ->
  Event.Listener maxCalls, callback
    .attach this

type.defineFrozenValues (_, options = {}) ->

  _async: options.async

  _argTypes: options.argTypes

# If a callback was passed, create a Listener
# that listens until this Event is GC'd.
type.initInstance (callback) ->
  callback and
    Event.Listener callback
    .attach this
    .start()

type.defineGetters

  listenable: ->
    @_listenable or @_createListenable()

  listenerCount: ->
    if @_listeners
    then @_listeners.length
    else 0

  hasListeners: ->
    @listenerCount > 0

type.defineMethods

  emit: ->
    isDev and validateArgs arguments, @_argTypes
    @_listeners and @_listeners.notify arguments
    return

  bindEmit: ->
    @_boundEmit or @_createBoundEmit()

  applyEmit: (args) ->
    @emit.apply this, args

  reset: ->
    @_listeners and @_listeners.reset()
    return

  _onAttach: (listener) ->
    listeners = @_listeners or @_createListeners()
    listeners.attach listener
    Event.didAttach.emit listener, this
    return

  _onDetach: (listener) ->
    @_listeners.detach listener
    return

  _createBoundEmit: ->
    frozen.define this, "_boundEmit",
      value: bind.method this, "emit"
    return @_boundEmit

  _createListenable: ->
    frozen.define this, "_listenable",
      value: (maxCalls, callback) =>
        Event.Listener(maxCalls, callback).attach this
    return @_listenable

  _createListeners: ->
    frozen.define this, "_listeners",
      value: ListenerArray {async: @_async}
    return @_listeners

type.defineStatics

  getListeners: (callback) ->
    listeners = []
    onAttach = @didAttach (listener) ->
      listeners.push listener.start()
    onAttach.start()
    callback()
    onAttach.detach()
    return listeners

  didAttach: get: ->

    frozen.define this, "didAttach",
      value: didAttach = Event()

    # Prevent 'didAttach' from triggering itself.
    frozen.define didAttach, "_onAttach",
      value: (listener) ->
        listeners = @_listeners or @_createListeners()
        listeners.attach listener
        return

    return didAttach

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
