package main

import (
	"github.com/gorilla/websocket"
)

type WSSession struct {
	Conn     *websocket.Conn
	Nickname string
}
