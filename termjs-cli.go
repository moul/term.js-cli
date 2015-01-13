package main

import (
	"fmt"

	"github.com/oguzbilgic/socketio"
)

func main() {
	// Open a new client connection to the given socket.io server
	// Connect to the given channel on the socket.io server
	socket, err := socketio.DialAndConnect("http://localdocker.xxx:8080", "/", "AAA=BBB")
	if err != nil {
		panic(err)
	}

	err = socket.Send(&socketio.Message{2, "2", socketio.NewEndpoint("/", ""), "[\"create\", 80, 25]"})
	if err != nil {
		panic(err)
	}

	for {
		// Receive socketio.Message from the server
		msg, err := socket.Receive()
		if err != nil {
			panic(err)
		}

		fmt.Printf("Type: %v, ID: '%s', Endpoint: '%s', Data: '%s' \n", msg.Type, msg.ID, msg.Endpoint, msg.Data)
	}
}
