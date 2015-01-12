#!/usr/bin/env coffee

socketio = require 'socket.io-client'

socket = socketio.connect('localdocker.xxx:8080')

socket.on 'connect', ->
  console.log "socket.on(connect)"
  pty = null

  socket.on 'data', (pty, data) ->
    console.log "socket.on(data) -> #{pty} #{data}"

  socket.on 'disconnect', ->
    console.log "socket.on(disconnect)"

  socket.emit 'create', 80, 25, (err, data) ->
    console.log 'create callback', err, data
    pty = data.id

  setTimeout (->
    socket.emit('data', pty, 'ls -la\n')
  ), 1000
