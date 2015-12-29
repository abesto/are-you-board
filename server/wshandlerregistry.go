package main

import (
	"github.com/gorilla/websocket"
)

type WSHandler func([]byte, WSSession, SocketRegistry) (error, *websocket.Conn)

type WSHandlerRegistry struct {
	handlers map[string]WSHandler
}

func NewWSHandlerRegistry() WSHandlerRegistry {
	return WSHandlerRegistry{map[string]WSHandler{}}
}

func (r WSHandlerRegistry) Register(name string, handler WSHandler) {
	if _, ok := r.handlers[name]; ok {
		panic("WSHandler with name " + name + " is already registered")
	}
	r.handlers[name] = handler
}

func (r WSHandlerRegistry) Get(name string) WSHandler {
	return r.handlers[name]
}

// Room for optimization: turn WSHandlerRegistry into an interface,
// implement a Freeze() method returning an immutable registry with
// the name list calculated once in Freeze()
func (r WSHandlerRegistry) HandlerNames() []string {
	keys := []string{}
	for key, _ := range r.handlers {
		keys = append(keys, key)
	}
	return keys
}
