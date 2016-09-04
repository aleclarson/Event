var Event, inject;

Event = require("./Event");

Event.Map = require("./EventMap");

Event.Listener = require("./Listener");

Event.ListenerArray = require("./ListenerArray");

inject = require("Builder/inject");

inject("Event", Event);

module.exports = Event;

//# sourceMappingURL=map/index.map
