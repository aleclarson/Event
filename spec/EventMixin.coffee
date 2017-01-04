
Type = require "Type"

EventMixin = require "../js/EventMixin"

describe "EventMixin", ->

  Person = null
  beforeAll ->
    type = Type "Person"
    type.addMixin EventMixin,
      eat: {food: String}
      think: {thought: String}
    Person = type.build()

  it "provides an 'emit' method", ->
    person = Person()
    emit = -> person.emit "eat", "taco"
    expect(emit).not.toThrow()
    emit = -> person.emit "eat", null
    expect(emit).toThrow()

  it "provides a 'once' method", ->
    {calls} = spy = jasmine.createSpy()
    person = Person()
    person.once("eat", spy).start()
    person.emit "eat", "taco"
    person.emit "eat", "cake"
    expect(calls.count()).toBe 1
    expect(calls.argsFor 0).toEqual ["taco"]

  it "provides an 'on' method", ->
    {calls} = spy = jasmine.createSpy()
    person = Person()
    person.on("eat", spy).start()
    person.emit "eat", "taco"
    person.emit "eat", "cake"
    expect(calls.count()).toBe 2
    expect(calls.argsFor 0).toEqual ["taco"]
    expect(calls.argsFor 1).toEqual ["cake"]
