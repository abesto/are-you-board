package main

import (
	"encoding/json"
	"log"

	"github.com/gopherjs/websocket"
	"honnef.co/go/js/dom"

	"github.com/abesto/are-you-board/shared"
)

var conn *websocket.Conn

func write(obj interface{}) (int, error) {
	buf, err := json.Marshal(obj)
	if err != nil {
		return -1, err
	}
	return conn.WriteString(string(buf))
}

func read(into interface{}) error {
	bufsize := 1024
	buf := make([]byte, bufsize)
	var content []byte
	var err error
	n := 0
	for {
		n, err = conn.Read(buf)
		if err != nil {
			return err
		}
		content = append(content, buf[:n]...)
		if n < bufsize {
			break
		}
	}
	return json.Unmarshal(content, &into)
}

func main() {
	var err error
	conn, err = websocket.Dial("ws://localhost:8080/ws/chat")
	if err != nil {
		log.Print("Failed to connect to websocket server")
		log.Print(err)
		return
	}

	window := dom.GetWindow()
	nickname := window.Prompt("Nickname", "")

	if err != nil {
		handleError(err)
	}

	write(shared.Ohai{Nickname: nickname})
	write(shared.ChatMessageWithoutSender{Message: "client originated this message"})

	var msg shared.ChatMessage
	for {
		err = read(&msg)
		if err != nil {
			handleError(err)
		}
		log.Print(msg)
	}
}

func handleError(err error) {
	log.Print(err)
}
