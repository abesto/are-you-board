package main

import (
	"encoding/json"
	"sync"

	"github.com/gorilla/websocket"
)

// +gen set
type Conn websocket.Conn

func (connections ConnSet) WriteMessage(msgType int, bytes []byte) (error, *websocket.Conn) {
	for socket := range connections {
		var wsocket = (*websocket.Conn)(socket)
		err := wsocket.WriteMessage(msgType, bytes)
		if err != nil {
			return err, wsocket
		}
	}
	return nil, nil
}

func (connections ConnSet) WriteJson(obj interface{}) (error, *websocket.Conn) {
	outp, err := json.Marshal(obj)
	if err != nil {
		return err, nil
	}
	return connections.WriteMessage(websocket.TextMessage, outp)
}

type SocketRegistry struct {
	lock sync.RWMutex
	m    map[string]ConnSet
}

func NewSocketRegistry() SocketRegistry {
	return SocketRegistry{m: make(map[string]ConnSet)}
}

func (r SocketRegistry) Add(to string, conn *websocket.Conn) {
	r.lock.Lock()
	if r.m[to] == nil {
		r.m[to] = NewConnSet()
	}
	r.m[to].Add((*Conn)(conn))
	r.lock.Unlock()
}

func (r SocketRegistry) Remove(from string, conn *websocket.Conn) {
	r.lock.Lock()
	if r.m[from] != nil {
		r.m[from].Remove((*Conn)(conn))
	}
	r.lock.Unlock()
}

func (r SocketRegistry) Get(name string) ConnSet {
	r.lock.RLock()
	conns := r.m[name]
	r.lock.RUnlock()
	return conns
}
