
# event v1.0.0 [![stable](http://badges.github.io/stability-badges/dist/stable.svg)](http://github.com/badges/stability-badges)

```coffee
Event = require "event"

onLoad = Event (error, data) ->
  console.log "Main listener fired: " + data

listener2 = onLoad (finished) ->
  console.log "Second listener fired!"

onLoad.once (finished) ->
  console.log "One-time listener fired!"

onLoad.emit null, 100                           # All three listeners will fire.

onLoad.remove listener2

onLoad.emit null, 200                           # Only one listener will fire.
```
