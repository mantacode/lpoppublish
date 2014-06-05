events = require 'events'
redis = require 'redis'

class LPopPublish extends events.EventEmitter
  constructor: (subscriber, publisher) ->

    @running = false
    @_queues_in = []
    @_channels_in = []
    @_queues_out = []
    @_channels_out = []

    # when we are asked to remove channels we will unsubscribe from each one
    @onUnsubscribe = (channels) =>
      @unsubcribe channels
    @on 'remove _channels_in', @onUnsubscribe

    # when we are asked to add channels we will subscribe to each one
    @onSubscribe = (channels) =>
      if @running
        @subscribe channels
    @on 'add _channels_in', @onSubscribe

    # when we are asked to handle a message we will propagate it
    @onMessage = (channel, message) =>
      @propagate message

    # call when we pop a message either from lpop call or blpop
    @onPop = (err, message) =>
      if err?
        throw err
      if message?
        @propagate message

    # make sure the queue has lpop an blpop or use a new client
    if queue? and queue.lpop? and queue.blpop
      @subscriber = queue
    else
      @subscriber = redis.createClient()

    # make sure the publisher has publish an lpush or use a new client
    if publisher? and publisher.publish? and publisher.lpush?
      @publisher = publisher
    else
      @publisher = redis.createClient()

  _paramsAsList: (args, next) ->
    if args.length == 0
      next()
    else if args.length == 1
      next args[0]
    else
      args = Array.prototype.slice.call args
      next args

  # creates a new setter / getter method for a list
  _list: (name, list) ->
    if list
      if list instanceof Array
        if @[name].length > 0
          @emit 'remove '+name, @[name]
        @[name] = list
        @emit 'add '+name, @[name]
      else
        @[name] = [String(list)]
        @emit 'add '+name, @[name]
      @
    else
      @[name]
  
  # creates a new setter / getter method for an int
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

  # the queues we read from
  queuesIn: () -> @_paramsAsList arguments, (list) => @_list '_queues_in', list

  # the channels we subscribe to
  channelsIn: () -> @_paramsAsList arguments, (list) => @_list '_channels_in', list

  # the queues we write to
  queuesOut: () -> @_paramsAsList arguments, (list) => @_list '_queues_out', list

  # the channels we publish to
  channelsOut: () -> @_paramsAsList arguments, (list) => @_list '_channels_out', list

  # the polling interval (for lpop)
  interval: (int) -> @_int '_interval', int

  # the number of requests we make each interval (for lpop)
  requests: (int) -> @_int '_requests', int

  # propagate a message to the outgoing channels and queues
  propagate: (message) ->

    for channel in @channelsOut()
      @propagateChannel channel, message

    for queue in @queuesOut()
      @propagateQueue queue, message

  # propagates a message to the queue
  propagateQueue: (queue, message) ->
    console.log  'pq %s, %s', queue, message
    @publisher.lpush @queue, @message
  
  # propagates a message to the channel
  propagateChannel: (channel, message) ->
    console.log  'pc %s, %s', channel, message
    @publisher.publish channel, message

  # subscribes to the incomming channels you can pass them.  by default the
  # incomming channels are used
  subscribe: (channels) -> @_eachChannel channels, 'subscribe'

  # unsubscribes to the incomming channels you can pass them. by defalt the]
  # icomming channels are used
  unsubscribe: (channels) -> @_eachChannel channels, 'unsubscribe'

  # calls "action" on the scubriber for each channel
  _eachChannel: (channels, action) ->
    channels = channels or @channelsIn()
    for channel in channels
      @subscriber[action] channel

  # start the process which will subscribe to the in channels and pop the queue
  start: (norun, action) ->
    if !@running
      @running = true
      @emit 'start'
      if !norun
        action = action || 'lpop'
        tick = =>
          if @running
            @run action
            if @interval() == 1
              setImmediate tick
            else
              setTimeout tick, @interval()
        tick()
    @

  # stop the process which will unsubcsriube from the in channels
  stop: ->
    @running = false
    @emit 'stop'
    @

  # pop from queues and publish
  run: (action) ->
    name = action || 'lpop'
    name = 'on' + name.charAt(0).toUpperCase() + name.slice(1)
    if not @[name]
      throw new Error('Unsupported action "'+action+'"')
    @[name]()
    @

  onLpop: () =>
    i = 0
    while i < @requests()
      for queue in @queuesIn()
        @subscriber.lpop queue, @onPop
      i++
    @

  onBlpop: () =>
    @subscriber.blpop @queuesIn, @onPop

LPopPublish.make = (queue, publisher) ->
  return new LPopPublish queue, publisher

module.exports = LPopPublish
