
# Event v2.1.0 ![stable](https://img.shields.io/badge/stability-stable-4EBA0F.svg?style=flat)

A modern approach to event handling in JavaScript:

- `Event`: The basic event emitter.
- `Event.Map`: Centralizes many event emitters.
- `Event.Listener`: The basic event listener.
- `Event.ListenerArray`: Centralizes many event listeners.

#### Creating an `Event`

```coffee
Event = require "Event"

didEmit = Event ->
  # The callback is optional, and called on every emit.

# The number of attached listeners.
didEmit.listenerCount
```

#### Creating an `Event.Listener`

First, let's create an `Event.Listener` that detaches itself from
its `Event` after just one emit.

```coffee
listener = didEmit 1, ->
  console.log "didEmit!"

# You must manually start the Listener.
listener.start()

# Likewise, you must manually stop the Listener.
# (This lifecycle wouldn't exist if JavaScript had weak references)
listener.stop()
```

Next, let's create an `Event.Listener` that never detaches itself.
In other words, it will listen **forever**.

```coffee
listener = didEmit ->
  console.log "didEmit!"

listener.start()

listener.stop()
```

#### Emitting an `Event`

```coffee
# Multiple arguments are supported.
didEmit.emit 1, 2, 3

# Feel free to use `call` or `apply` to set the context.
didEmit.apply this, arguments
```

#### There's more!

But you'll have to read the source code for now...
