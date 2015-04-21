#!/usr/bin/env coffee

socketio = require 'socket.io-client'
readline = require 'readline'
tty = require 'tty'

class TermJSCli

  constructor: (@opts, cb=null) ->
    @socket = null
    @pty = null
    @stats =
      received: 0
      sent: 0
    process.nextTick -> cb @ if cb
    return @


  connect: (cb=null) =>
    @socket = socketio.connect(@opts.url)

    @pty = null
    @stdin = process.stdin
    @stdin.setRawMode true
    @stdin.resume()
    @stdin.setEncoding 'utf8'

    @stdin.on 'data', (key) =>
      if key.toString() == String.fromCharCode(0x11)
        @stdin.pause()
        @socket.disconnect()
        process.exit()
      else
        @socket.emit 'data', @pty, key

    @socket.on 'connect', =>
      @socket.emit 'create', 80, 25, (err, data) =>
        @pty = data.id

        if @opts.sendNewLineOnConnect
          @send '\n'
        @setupReceiver cb

    @socket.on 'error', => console.log 'error'
    @socket.on 'disconect', => console.log 'disconnect'
    @socket.on 'reconect', => console.log 'reconnect'
    @socket.on 'reconecting', => console.log 'reconnecting'
    @socket.on 'reconect_failed', => console.log 'reconnect_failed'


  setupReceiver: (cb=null) =>
    cb null, @ if cb?

    @socket.on 'data', (@pty, data) =>
      if data == 'Connection closed.\r\n'
        console.log "<<[#{new Buffer(data).toString('hex')}]"
        @socket.disconnect()
        @socket.socket.connect()
      @stats.received += 1
      if @stats.received == 1 and @opts.sendNewLineOnConnect and data == '\r\n'
        return
      process.stdout.write data


  send: (line) =>
    @socket.emit 'data', @pty, line


module.exports = TermJSCli
