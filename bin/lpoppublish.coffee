#!/usr/bin/env coffee

pkg = require '../package.json'

list = (v) -> v.split ','
int = (v) ->
  v = parseInt v
  if isNaN v
    v = 1
  else
    v = Math.abs v
  v || 1

app = require 'commander'
app
  .version(pkg.version)
  .usage('[options]')
  .option('-q, --queues <string>', 'the queues to read from', list)
  .option('-c, --channels <string>', 'the channels to write to', list)
  .option('-i, --interval <number>', 'the number of miliseconds to wait before polling', int)
  .option('-r, --requests <number>', 'the number of requests to make each interval', int)
  .parse(process.argv)

app.help() if !app.channels or !app.queues

lpoppublish = module.exports = require('./..').make()
  .queues(app.queues)
  .channels(app.channels)
  .interval(app.interval)
  .requests(app.requests)
  .start()
