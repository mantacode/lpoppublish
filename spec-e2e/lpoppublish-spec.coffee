exec = require('child_process').exec

describe 'lpoppublish should listen for data on given lists and publish data onto given channels', ->

  Given -> @lists = ['la', 'lb', 'lc']
  Given -> @channels = ['ca', 'cb', 'cc']
  Given -> @max = @lists.length * @channels.length
  Given -> @count = 0
  Given -> @captured = {}
  Given -> @command = __dirname + '/../bin/lpoppublish.coffee -q ' + @lists.join(',') + ' -c ' + @channels.join(',')

  Given ->
    @subscriber = require('redis').createClient()
    @subscriber.subscribe channel for channel in @channels
  Given -> @publisher = require('redis').createClient()

  Given -> @lpoppublish = exec @command, (err, stdout, stderr) ->

  Given (done) ->
    @subscriber.on 'message', (channel, message) =>
      # capture the message and increment our message count
      @captured[channel] = @captured[channel] || []
      @captured[channel].push message
      if ++@count == @max
        @lpoppublish.kill()
        @subscriber.end()
        @publisher.end()
        done()
    @publisher.lpush([list], list, (err, res) ->) for list in @lists

  Then ->
    expect(@count).toBe @max
    for channel in @channels
      expect(@captured[channel].length).toBe @lists.length
      for list in @lists
        expect(@captured[channel].indexOf(list)).toBeGreaterThan -1

