package main

import (
	"encoding/json"
	"io"
	"log"

	"github.com/gopherjs/websocket"

	"github.com/abesto/are-you-board/shared"
)

var conn *websocket.Conn

// TODO the value of handlers should be sets
var handlers map[string][]wsHandler = make(map[string][]wsHandler)
var listening bool = false

type wsHandler func(content []byte)

func wsConnect() error {
	var err error
	conn, err = websocket.Dial("ws://localhost:8080/ws/chat")
	if err != nil {
		log.Fatal("Failed to connect to websocket server")
		log.Fatal(err)
	}
	return err
}

func wsListen() {
	if listening {
		return
	}
	listening = true
	decoder := json.NewDecoder(conn)
	for {
		var envelope shared.WSEnvelope
		if err := decoder.Decode(&envelope); err == io.EOF {
			log.Print("Websocket connection closed by server")
			break
		} else if err != nil {
			log.Fatal(err)
		}
		for _, handler := range handlers[envelope.Name] {
			go handler(envelope.Content)
		}
	}
}

func wsOn(name string, handler wsHandler) {
	if handlers[name] == nil {
		handlers[name] = []wsHandler{handler}
	} else {
		handlers[name] = append(handlers[name], handler)
	}
}

func wsWrite(name string, obj interface{}) (int, error) {
	var content, envelopeBuffer []byte
	var err error
	content, err = json.Marshal(obj)
	if err != nil {
		return -1, err
	}
	envelope := shared.WSEnvelope{
		Name:    name,
		Content: content,
	}
	envelopeBuffer, err = json.Marshal(envelope)
	if err != nil {
		return -1, err
	}
	return conn.WriteString(string(envelopeBuffer))
}
