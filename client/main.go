package main

import (
	"log"
	"encoding/json"
	
	"github.com/gopherjs/jquery"

	"github.com/abesto/are-you-board/shared"
)

func main() {
	jquery.Get("/msg", nil, nil, "text").Done(func (response string) {
		var msg shared.ChatMessage
		json.Unmarshal([]byte(response), &msg)
		log.Print(msg)
		log.Print(msg.Message)
	})
}
