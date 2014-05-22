describe 'lpoppublish', ->

  Given ->
    @subscriber = lpop: (list, cb) ->
      cb null, 'message'
    spyOn(@subscriber,'lpop').andCallThrough()

  Given ->
    @publisher = publish: (channel, message) ->
    spyOn(@publisher,'publish').andCallThrough()

  Given -> @lpoppublish = require './../../lib/lpoppublish'

  describe '#make', ->
    Given -> @res = @lpoppublish.make @subscriber, @publisher
    Then -> expect(typeof @res).toBe 'object'
    And -> expect(@res instanceof @lpoppublish).toBe true

  describe 'an instance', ->

    Given ->
      @instance = @lpoppublish.make @subscriber, @publisher
      spyOn(@instance,'start').andCallThrough()
      spyOn(@instance,'stop').andCallThrough()
      spyOn(@instance,'run').andCallThrough()

    describe '#queues', ->
        
      context 'with no arguments', ->
        When -> @res = @instance.queues()
        Then -> expect(@res).toEqual []

      context 'with arguments', ->
        When -> @res = @instance.queues('a').queues()
        Then -> expect(@res).toEqual ['a']

    describe '#channels', ->

      context 'with no arguments', ->
        When -> @res = @instance.channels()
        Then -> expect(@res).toEqual []

      context 'with arguments', ->
        When -> @res = @instance.channels('a').channels()
        Then -> expect(@res).toEqual ['a']

    describe '#start', ->
      # passing true will keep the app from running
      When -> @instance.start true
      Then -> expect(@instance.running).toBe true

    describe '#stop', ->
      When -> @instance.stop()
      Then -> expect(@instance.running).toBe false

    describe '#run', ->
      Given -> @instance.queues 'a'
      Given -> @instance.channels 'a'
      When -> @instance.run()
      Then -> expect(@subscriber.lpop).toHaveBeenCalled()
      And -> expect(@publisher.publish).toHaveBeenCalled()
