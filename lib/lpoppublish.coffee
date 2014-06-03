redis = require 'redis'

class LPopPublish
  constructor: (queue, publisher) ->
    @running = false
    @_queues = []
    @_channels = []

    if queue? and queue.lpop?
      @queue = queue
    else
      @queue = redis.createClient()

    if publisher? and publisher.publish?
      @publisher = publisher
    else
      @publisher = redis.createClient()

  _list: (name, list) ->
    if list
      if list instanceof Array
        @[name] = list
      else
        @[name] = [list]
      @
    else
      @[name]

  _int: (name, int) ->
    if !isNaN(int)
      @[name] = int
      @
    else
      if !@[name]
        @[name] = 1
      else if @[name] < 0
        @[name] = Math.abs @[name]
      @[name]

  queues: (list) -> @_list '_queues', list

  channels: (list) -> @_list '_channels', list

  interval: (int) -> @_int '_interval', int

  requests: (int) -> @_int '_requests', int

  start: (norun) ->
    if !@running
      @running = true
      if !norun
        tick = =>
          if @running
            @run()
            if @interval() == 1
              setImmediate tick
            else
              setTimeout tick, @interval()
        tick()
    @

  stop: ->
    @running = false
    @

  run: ->
    i = 0
    while i < @requests()
      for queue in @queues()
        @queue.lpop queue, (err, message) =>
          if err?
            throw err
          if message?
            for channel in @channels()
              @publisher.publish channel, message
      i++
    @

LPopPublish.make = (queue, publisher) ->
  return new LPopPublish queue, publisher

module.exports = LPopPublish
