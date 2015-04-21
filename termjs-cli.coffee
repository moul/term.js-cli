#!/usr/bin/env coffee

socketio = require 'socket.io-client'
readline = require 'readline'


class TermJSCli

  constructor: (@opts, cb=null) ->
    @socket = null
    @pty = null
    @rl = null
    @stats =
      received: 0
      sent: 0
    process.nextTick -> cb @ if cb
    return @


  connect: (cb=null) =>
    @socket = socketio.connect(@opts.url)

    @pty = null
    @rl = readline.createInterface
      input: process.stdin
      output: process.stdout

    @rl.on 'line', (line) =>
      @stats.sent += 1
      @socket.emit 'data', @pty, "#{line}\n"

    @rl.on 'SIGINT', =>
      @rl.pause()
      @socket.disconnect()

    @socket.on 'connect', =>
      @socket.emit 'create', 80, 25, (err, data) =>
        @pty = data.id

        if @opts.sendNewLineOnConnect
          @send '\n'
        @setupReceiver cb


  setupReceiver: (cb=null) =>
    cb null, @ if cb?

    @socket.on 'data', (@pty, data) =>
      @stats.received += 1
      if @stats.received == 1 and @opts.sendNewLineOnConnect and data == '\r\n'
        return
      process.stdout.write data


  send: (line) =>
    @socket.emit 'data', @pty, line


module.exports = TermJSCli
