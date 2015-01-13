#!/usr/bin/env coffee

socketio = require 'socket.io-client'
readline = require 'readline'

url = process.argv[2]

socket = socketio.connect(url)

pty = null
rl = readline.createInterface
  input: process.stdin
  output: process.stdout

rl.on 'line', (line) ->
  socket.emit 'data', pty, "#{line}\n"

rl.on 'SIGINT', ->
  rl.pause()
  socket.disconnect()

socket.on 'connect', ->
  socket.on 'data', (pty, data) ->
    process.stdout.write data

  socket.emit 'create', 80, 25, (err, data) ->
    pty = data.id
