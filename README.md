
# event v1.0.0 [![stable](http://badges.github.io/stability-badges/dist/stable.svg)](http://github.com/badges/stability-badges)

`Event` and `Listener` classes with a modern syntax.

```coffee
Event = require "event"

didEmit = Event()

listener = didEmit ->
  console.log "Emit detected!"

didEmit.emit()

listener.calls    # => 1
listener.maxCalls # => Infinity

listener.stop()
```

## Event

An `Event` is responsible for storing and notifying its associated `Listener`s.

#### Properties

- `listenable: Object { get }` - A proxy for creating `Listener`s for this `Event`. Does not allow `emit` calls.

#### Methods

- `emit(args...) -> Void` - Notifies all `Listener`s with the given arguments.
- `emitArgs(args) -> Void` - Notifies all `Listener`s with the given array.
- `this(onEvent: Function, maxCalls: [ Number, Void ]) -> Listener` - Creates a `Listener` for this `Event`. It will listen forever; unless stopped.
- `once(onEvent: Function) -> Listener` - Creates a `Listener` for this `Event`. It will listen once; unless stopped.
- `many(maxCalls: Number, onEvent: Function)` - Creates a `Listener` for this `Event`. It will listen up to `maxCalls` times; unless stopped.
- `reset() -> Void` - Removes all associated `Listener`s.

## Listener

A `Listener` is responsible for calling its handler and tracking how many calls before listening stops.

You should let the `Event` create & manage its `Listener`s. In most cases, you only need to touch a `Listener` if you want to call `listener.stop()`. Just remember that `event.reset()` exists for stopping every active `Listener`.

#### Properties

- `calls: Number { get }`
- `maxCalls: Number { get }`

#### Methods

- `notify(scope, args) -> Boolean` - Calls the handler, stops listening if necessary, and returns true if still listening.
- `stop() -> Void` - Detaches the `Listener` from its `Event`; preventing the handler from being called.
