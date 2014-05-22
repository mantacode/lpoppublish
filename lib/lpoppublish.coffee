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

  queues: (list) -> @_list '_queues', list

  channels: (list) -> @_list '_channels', list

  start: (norun) ->
    if !@running
      @running = true
      if !norun
        tick = =>
          if @running
            @run()
            setImmediate tick
        tick()
    @

  stop: ->
    @running = false
    @

  run: ->
    for queue in @queues()
      @queue.lpop queue, (err, message) =>
        if err?
          throw err
        if message?
          for channel in @channels()
            @publisher.publish channel, message
    @

LPopPublish.make = (queue, publisher) ->
  return new LPopPublish queue, publisher

module.exports = LPopPublish
