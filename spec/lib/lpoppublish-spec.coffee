describe 'LPopPublish', ->

  Given ->
    @subscriber =
      lpop: (list, cb) ->
        cb null, 'message'
      blpop: (list, cb) ->
        cb null, 'message'
      subscribe: (channel) ->
      unsubscribe: (channel) ->
    spyOn(@subscriber,'lpop').andCallThrough()
    spyOn(@subscriber,'blpop').andCallThrough()

  Given ->
    @publisher =
      publish: (channel, message) ->
      lpush: (queue, message) ->
    spyOn(@publisher,'publish').andCallThrough()

  Given -> @lpoppublish = require './../../lib/lpoppublish'

  describe '#make subscriber:Object, publisher:Object', ->
    Given -> @res = @lpoppublish.make @subscriber, @publisher
    Then -> expect(typeof @res).toBe 'object'
    And -> expect(@res instanceof @lpoppublish).toBe true

  context 'prototype', ->

    Given ->
      @instance = @lpoppublish.make @subscriber, @publisher
      spyOn(@instance,'start').andCallThrough()
      spyOn(@instance,'stop').andCallThrough()
      spyOn(@instance,'run').andCallThrough()

    describe '#queuesIn', ->
        
      When -> @res = @instance.queuesIn()
      Then -> expect(@res).toEqual []

      describe 'queues:String="a"', ->

        When -> @res = @instance.queuesIn('a').queuesIn()
        Then -> expect(@res).toEqual ['a']

      describe 'queues:String=["a"]', ->

        When -> @res = @instance.queuesIn(['a']).queuesIn()
        Then -> expect(@res).toEqual ['a']

      context '0:String="a", 1:String="b", 2:String="c"', ->

        When -> @res = @instance.queuesIn('a', 'b', 'c').queuesIn()
        Then -> expect(@res).toEqual ['a','b','c']

    describe '#channelsIn', ->

      When -> @res = @instance.channelsIn()
      Then -> expect(@res).toEqual []

      describe 'channels:String="a"', ->

        Given -> @channel = 'a'
        When -> @res = @instance.channelsIn(@channel).channelsIn()
        Then -> expect(@res).toEqual [@channel]

      describe 'channel:String=["a"]', ->

        When -> @res = @instance.channelsIn(['a']).channelsIn()
        Then -> expect(@res).toEqual ['a']

      context '0:String="a", 1:String="b", 2:String="c"', ->

        When -> @res = @instance.channelsIn('a', 'b', 'c').channelsIn()
        Then -> expect(@res).toEqual ['a','b','c']

      context 'channels already defined', ->

        Given -> @oldChannel = 'a'
        Given -> @channel = 'b'
        Given -> @instance.channelsIn @channel
        Given -> spyOn(@instance,['emit']).andCallThrough()
        Given -> spyOn(@instance,['onUnsubscribe']).andCallFake()
        When -> @res = @instance.channelsIn(@channel).channelsIn()
        Then -> expect(@res).toEqual [@channel]
        And -> expect(@instance.emit).toHaveBeenCalledWith 'add _channels_in', [@channel]

    describe '#queuesOut', ->
        
      When -> @res = @instance.queuesOut()
      Then -> expect(@res).toEqual []

      context 'queues:String="a"', ->

        When -> @res = @instance.queuesOut('a').queuesOut()
        Then -> expect(@res).toEqual ['a']

      context 'queues:String=["a"]', ->

        When -> @res = @instance.queuesOut(['a']).queuesOut()
        Then -> expect(@res).toEqual ['a']

      context '0:String="a", 1:String="b", 2:String="c"', ->

        When -> @res = @instance.queuesOut('a', 'b', 'c').queuesOut()
        Then -> expect(@res).toEqual ['a','b','c']

    describe '#channelsOut', ->

      When -> @res = @instance.channelsOut()
      Then -> expect(@res).toEqual []

      context 'channels:String="a"', ->

        When -> @res = @instance.channelsOut('a').channelsOut()
        Then -> expect(@res).toEqual ['a']

      context 'channels:String=["a"]', ->

        When -> @res = @instance.channelsOut(['a']).channelsOut()
        Then -> expect(@res).toEqual ['a']

      context '0:String="a", 1:String="b", 2:String="c"', ->

        When -> @res = @instance.channelsOut('a', 'b', 'c').channelsOut()
        Then -> expect(@res).toEqual ['a','b','c']

    describe '#requests', ->

      When -> @res = @instance.requests()
      Then -> expect(@res).toEqual 1

      context 'v:Number=2', ->
        When -> @res = @instance.requests(2).requests()
        Then -> expect(@res).toEqual 2

      context 'v:Nnumber=-2', ->
        When -> @res = @instance.requests(-2).requests()
        Then -> expect(@res).toEqual 2

    describe '#interval', ->

      When -> @res = @instance.interval()
      Then -> expect(@res).toEqual 1

      context 'v:Number=100', ->
        When -> @res = @instance.interval(100).interval()
        Then -> expect(@res).toEqual 100

      context 'v:Number=-100', ->
        When -> @res = @instance.interval(-100).interval()
        Then -> expect(@res).toEqual 100

    describe '#onMessage channel:String="channel", message:Mixed="message"', ->

      Given -> @channel = 'channel'
      Given -> @message = 'message'
      Given -> spyOn(@instance,['propagate']).andCallThrough()
      When -> @instance.onMessage @channel, @message
      Then -> expect(@instance.propagate).toHaveBeenCalledWith @message

    describe '#propagate message:Mixed="message"', ->

      Given -> @name = 'queue'
      Given -> @channel = 'channel'
      Given -> @message = 'message'
      Given -> @instance.queuesOut @name
      Given -> @instance.channelsOut @channel 
      Given -> spyOn(@instance, ['propagateChannel']).andCallThrough()
      Given -> spyOn(@instance, ['propagateQueue']).andCallThrough()
      When -> @instance.propagate @message
      Then -> expect(@instance.propagateChannel).toHaveBeenCalledWith @channel, @message
      And -> expect(@instance.propagateQueue).toHaveBeenCalledWith @name, @message

    describe '#propagateChannel channel:String="channel", message:Mixed="message"', ->

      Given -> @channel = 'channel'
      Given -> @message = 'message'
      When -> @instance.propagateChannel @channel, @message
      Then -> expect(@publisher.publish).toHaveBeenCalledWith @channel, @message
      
    
    describe '#propagateQueue queue:String="queue", message:Mixed="message"', ->

      Given -> @name = 'queue'
      Given -> @message = 'message'
      Given -> spyOn(@publisher, ['lpush'])
      When -> @instance.propagateQueue @name, @message
      Then -> expect(@publisher.lpush).toHaveBeenCalledWith @name, @message

    describe '#unsubscribe', ->

      Given -> @channel = 'a'
      Given -> @instance.channelsIn @channel
      When -> @instance.unsubscribe
      And -> expect(@subscriber.unsubscribe).toHaveBeenCalledWith @channel

      context 'channels:Array=["a"]', ->

        Given -> @channel = 'a'
        Given -> @channels = [@channel]
        When -> @instance.unsubscribe @channels
        And -> expect(@subscriber.unsubscribe).toHaveBeenCalledWith @channel

    describe '#onUnsubscribe channels:Array=["a"]', ->

      Given -> @channel = 'a'
      Given -> @channels = [@channel]
      Given -> spyOn(@instance, ['unsubscribe']).andCallThrough()
      When -> @instance.onUnsubscribe @channels
      Then -> expect(@instance.unsubscribe).toHaveBeenCalledWith [@channel]

    describe '#subscribe', ->

      Given -> @channel = 'a'
      Given -> @instance.channelsIn @channel
      When -> @instance.subscribe
      And -> expect(@subscriber.subscribe).toHaveBeenCalledWith @channel

      context 'channels:Array=["a"]', ->

        Given -> @channel = 'a'
        Given -> @channels = [@channel]
        When -> @instance.subscribe @channels
        And -> expect(@subscriber.subscribe).toHaveBeenCalledWith @channel

    describe '#onSubscribe channels:Array=["a"]', ->

      Given -> @channel = 'a'
      Given -> @channels = [@channel]
      Given -> spyOn(@instance, ['subscribe']).andCallThrough()
      When -> @instance.onSubscribe @channels
      Then -> expect(@instance.subscribe).toHaveBeenCalledWith [@channel]

    describe '#start norun:Boolean=true', ->
      Given -> spyOn(@instance,['emit']).andCallThrough()
      Given -> spyOn(@instance,['onSubscribe']).andCallThrough()
      Given -> spyOn(@instance,['subscribe']).andCallThrough()
      Given -> spyOn(@instance,['run'])
      When -> @instance.start true
      Then -> expect(@instance.running).toBe true
      And -> expect(@instance.emit).toHaveBeenCalledWith 'start'
      And -> expect(@instance.onSubscribe).toHaveBeenCalledWith undefined
      And -> expect(@instance.subscribe).toHaveBeenCalledWith undefined


    describe '#stop', ->
      Given -> spyOn(@instance,['emit']).andCallThrough()
      Given -> spyOn(@instance,['onUnsubscribe']).andCallThrough()
      Given -> spyOn(@instance,['unsubscribe']).andCallThrough()
      When -> @instance.stop()
      Then -> expect(@instance.running).toBe false
      And -> expect(@instance.emit).toHaverBeenCalledWith 'stop'
      And -> expect(@instance.onUnsubscribe).toHaveBeenCalledWith undefined
      And -> expect(@instance.unsubscribe).toHaveBeenCalledWith undefined

    describe '#run', ->

      Given -> @instance.queuesIn 'a'
      Given -> @instance.channelsOut 'a'
      Given -> @action = 'lpop'
      When -> @instance.run @action
      Then -> expect(@subscriber.lpop).toHaveBeenCalled()
      And -> expect(@publisher.publish).toHaveBeenCalled()
      And -> expect(@publisher.lpush).toHaveBeenCalled()

      context 'action:String="lpop"', ->

        Given -> @instance.queuesIn 'a'
        Given -> @instance.channelsOut 'a'
        Given -> @action = 'lpop'
        When -> @instance.run @action
        Then -> expect(@subscriber.lpop).toHaveBeenCalled()
        And -> expect(@publisher.publish).toHaveBeenCalled()
        And -> expect(@publisher.lpush).toHaveBeenCalled()

      context 'action:Stringb="blpop"', ->

        Given -> @channelIn = 'a'
        Given -> @channelOut = 'b'
        Given -> @queueOut = 'b'
        Given -> @message = 'message'
        Given -> @instance.queuesIn @channelIn
        Given -> @instance.channelsOut @channelOut
        Given -> @instance.queuesOut @queueOut
        Given -> @action = 'lpop'
        When -> @instance.run @blpop
        Then -> expect(@subscriber.blpop).toHaveBeenCalled()
        And -> expect(@publisher.publish).toHaveBeenCalled @channelOut, @message
        And -> expect(@publisher.lpush).toHaveBeenCalled @queueOut, @message 

      context 'action:String="crap"', ->

        Given -> @action = 'crap'
        Then -> expect(@instance.run(@action)).toThrow new Error('Unsupported action "crap"')
