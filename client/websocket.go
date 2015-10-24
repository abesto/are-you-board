package main

import (
	"encoding/json"
	"github.com/gopherjs/websocket"
	"log"
)

var conn *websocket.Conn

func wsConnect() error {
	var err error
	conn, err = websocket.Dial("ws://localhost:8080/ws/chat")
	if err != nil {
		log.Print("Failed to connect to websocket server")
		log.Print(err)
	}
	return err
}

func wsWrite(obj interface{}) (int, error) {
	buf, err := json.Marshal(obj)
	if err != nil {
		return -1, err
	}
	return conn.WriteString(string(buf))
}

func wsRead(into interface{}) error {
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
