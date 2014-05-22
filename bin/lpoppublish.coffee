#!/usr/bin/env coffee

pkg = require '../package.json'

list = (v) -> v.split ','

app = require 'commander'
app
  .version(pkg.version)
  .usage('[options]')
  .option('-q, --queues <string>', 'the queues to read from', list)
  .option('-c, --channels <string>', 'the channels to write to', list)
  .parse(process.argv)

app.help() if !app.channels or !app.queues

lpoppublish = module.exports = require('./..').make()
  .queues(app.queues)
  .channels(app.channels)
  .start()
