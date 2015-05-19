package main

import (
	"fmt"
	"log"
	"net/url"
	"os"
	"strings"
	"time"

	"github.com/oguzbilgic/socketio"
	"golang.org/x/net/websocket"

	//"github.com/oguzbilgic/socketio"
)

func main() {
	origin := os.Args[1]

	parsedUrl, err := url.Parse(origin)
	if err != nil {
		panic(err)
	}

	host := parsedUrl.Host
	if !strings.Contains(host, ":") {
		if parsedUrl.Scheme == "https" {
			host = fmt.Sprintf("%s:443", host)
		} else {
			host = fmt.Sprintf("%s:80", host)
		}
	}
	user := ""
	if parsedUrl.User != nil {
		user = fmt.Sprintf("%s@", parsedUrl.User)
	}

	dialUrl := fmt.Sprintf("%s://%s%s", parsedUrl.Scheme, user, host)
	fmt.Println("dialUrl:", dialUrl)
	socket, err := socketio.DialAndConnect(dialUrl, "/", parsedUrl.RawQuery)

	if err != nil {
		panic(err)
	}

	ioUrl := strings.Replace(socket.URL, "https", "wss", 1) + "/socket.io/1/websocket/" + socket.Session.ID
	ioUrl = strings.Replace(socket.URL, "http", "ws", 1) + "/socket.io/1/websocket/" + socket.Session.ID
	fmt.Println("iourl:", ioUrl)

	ws, err := websocket.Dial(ioUrl, "", origin)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("websocket:", ws)

	go readFromServer(ws)
	time.Sleep(5e9)
	ws.Close()

}

func readFromServer(ws *websocket.Conn) {
	buf := make([]byte, 1000)
	for {
		if _, err := ws.Read(buf); err != nil {
			fmt.Printf("%s\n", err.Error())
			break
		}
	}
}
