package main

import (
	"encoding/json"
	"log"

	"github.com/gopherjs/jquery"
	"github.com/gopherjs/websocket"

	"github.com/abesto/are-you-board/shared"
)

func main() {
	jquery.Get("/msg", nil, nil, "text").Done(func(response string) {
		var msg shared.ChatMessage
		json.Unmarshal([]byte(response), &msg)
		log.Print(msg)
		log.Print(msg.Message)
		go wstest()
	})
}

func wstest() {
	c, err := websocket.Dial("ws://localhost:8080/ws/chat")
	if err != nil {
		handleError(err)
	}

	myMsg := shared.ChatMessageWithoutSender{Message: "client originated this message"}
	var buf []byte
	buf, err = json.Marshal(myMsg)
	if err != nil {
		handleError(err)
	}

	c.Send(string(buf))

	buf = make([]byte, 1024)
	var n int
	n, err = c.Read(buf)
	if err != nil {
		handleError(err)
	}
	var msg shared.ChatMessage
	json.Unmarshal(buf[:n], &msg)
	log.Print(string(buf[:n]))
	log.Print(msg)
}

func handleError(err error) {
	log.Print(err)
}
