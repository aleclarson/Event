
# Event v2.3.0 ![stable](https://img.shields.io/badge/stability-stable-4EBA0F.svg?style=flat)

Another take on events in Javascript.

```coffee
Event = require "Event"

obj =
  didShow: Event.sync()
  show: ->
    @didShow.emit()
```

#### `Event`

A simple event emitter.

If a function is provided as the first argument, it will be called on every `emit`.

**Options:**
- `async`: When true, all emits are delayed using `setImmediate`. Defaults to true.
- `argTypes`: An object of types used to validate `emit` arguments.

**Properties:**
- `emit`: The bound method for notifying any listeners (forwarding the context/args)
- `listenable`: Provides an interface for listening, but not emitting (lazily created)
- `listenerCount`: The number of attached `Event.Listener` instances
- `hasListeners`: Equals true if any listeners are attached

**Methods:**
- `reset()`: Removes all attached listeners and clears the emit queue. 

#### `Event.Listener`

In most situations, you will not create an `Event.Listener` using the constructor directly. Instead, pass a `Function` to an `Event` instance.

```coffee
listener = obj.didShow ->
  console.log "obj.didShow()"

# You must manually start each listener.
listener.start()

# And when finished, manually stop each listener.
listener.stop()
```

One-time listeners are also supported. As well as N-time listeners.

```coffee
listener = obj.didShow 1, ->
  console.log "once"
listener.start()

listener = obj.didShow 100, ->
  console.log "call: " + listener.calls
listener.start()
```

**Arguments:**
- `maxCalls`: The maximum number of times the listener will be called
- `callback`: The function that will be called

**Properties:**
- `calls`: The number of times the listener has been called so far
- `maxCalls`: Same as `arguments[0]`
- `isListening`: Equals true if the listener will handle new events

**Methods:**
- `onDetach(callback)`: Execute a function when the listener is detached
- `attach(event)`: Attaches the listener to an `Event`
- `detach()`: Detached the listener from its `Event`
- `start()`: Must be called for the listener to start listening
- `stop()`: Stop listening, but stay attached (useful if you plan to call `start` later on)

