
Event = require "./Event"

module.exports = (type, createListeners) ->

  kind = type._kind
  unless kind and kind::startListeners
    type.defineValues mixin.defineValues
    type.defineMethods mixin.methods

  defineListeners = (args) ->

    listeners = @__listeners
    onAttach = Event.didAttach (listener) ->
      listeners.push listener

    onAttach.start()
    createListeners.apply this, args
    onAttach.detach()

  if type.didMount
  then type.didMount defineListeners
  else type._phases.init.push defineListeners

mixin = {}

mixin.defineValues = ->

  __listeners: []

mixin.methods =

  startListeners: ->
    for listener in @__listeners
      listener.start()
    return

  stopListeners: ->
    for listener in @__listeners
      listener.stop()
    return
