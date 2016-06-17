
# Event v2.0.0 ![stable](https://img.shields.io/badge/stability-stable-4EBA0F.svg?style=flat)

Provides the `Event` and `Event.Listener` classes.

### Event.optionTypes

```coffee
# The function called on every 'emit'.
onNotify: Function.Maybe

# The function called whenever a listener is added or removed.
# The arguments look like [ listeners, listenerCount ].
onSetListeners: Function.Maybe

# The limit of how many times the event can
# call 'emit' while already emitting.
# This catches infinite recursion.
# Defaults to zero.
maxRecursion: Number
```

### Event.properties

```coffee
# The number of active listeners.
event.listenerCount

# A simple proxy for creating listeners.
# Does not include the 'emit' method.
event.listenable
```

### Event.prototype

```coffee
# Notify any listeners.
# Pass the given arguments.
event.emit 1, 2, 3

# Notify any listeners.
# Pass this array as the arguments.
event.emitArgs [ 1, 2, 3 ]

# Create an 'Event.Listener' with the given function.
# Listens until stopped manually.
listener = event ->

# Create an 'Event.Listener' with the given function.
# Listens once, then stops itself.
listener = event.once ->

# Create an 'Event.Listener' with the given function.
# Listens X times, then stops itself.
listener = event.many 5, ->

# Remove all listeners.
event.reset()
```

### Event.statics

```coffee
# The listener class.
# You normally do NOT call this manually.
listener = Event.Listener {}

# An event that emits every time
# an 'Event.Listener' is created.
listener = Event.didListen ->
```
