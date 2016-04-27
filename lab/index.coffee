
Event = require ".."

onLoad = Event (error, data) ->
  log
    .moat 1
    .white "Main listener fired: " + data
    .moat 1

listener2 = onLoad (finished) ->
  log
    .moat 1
    .white "Second listener fired!"
    .moat 1

onLoad.once (finished) ->
  log
    .moat 1
    .white "One-time listener fired!"
    .moat 1

onLoad.emit null, 100

onLoad.remove listener2

onLoad.emit null, 200
