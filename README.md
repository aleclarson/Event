
# Event v2.1.0 ![stable](https://img.shields.io/badge/stability-stable-4EBA0F.svg?style=flat)

A modern approach to event handling in JavaScript:

- `Event`: The basic event emitter.
- `Event.Listener`: The basic event listener.
- `Event.ListenerArray`: Retains and notifies all attached listeners.

#### `Event`

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

You typically create event listeners indirectly.

```coffee
# Create a listener that never stops.
listener = event -> console.log "hey"

# Create a listener that stops after 100 calls.
listener = event 100, -> console.log "hi"
```

For that reason, it's recommended you name your events like `willFoo` or `didFoo` so the syntax reads better.

**Arguments:**
- `maxCalls`: The maximum number of times the listener will be called
- `callback`: The function that will be called

**Properties:**
- `calls`: The number of times the listener has been called so far
- `maxCalls`: Same as `arguments[0]`
- `isListening`: Equals true if the listener will handle new events

**Methods:**
- `attach(event)`: Attaches the listener to an `Event`
- `detach()`: Detached the listener from its `Event`
- `start()`: Must be called for the listener to start listening
- `stop()`: Stop listening, but stay attached (useful if you plan to call `start` later on)

