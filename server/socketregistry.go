package main

import (
	"encoding/json"
	"sync"

	"github.com/gorilla/websocket"

	"github.com/abesto/are-you-board/shared"
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

func (connections ConnSet) WriteEnvelope(obj shared.WSEnvelope) (error, *websocket.Conn) {
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

func (r SocketRegistry) WriteJson(name string, obj interface{}) (error, *websocket.Conn) {
	content, err := json.Marshal(obj)
	if err != nil {
		return err, nil
	}
	envelope := shared.WSEnvelope{
		Name:    name,
		Content: content,
	}
	return r.Get(name).WriteEnvelope(envelope)
}

func (r SocketRegistry) ConnectionCount() map[string]int {
	val := map[string]int{}
	r.lock.RLock()
	for name, connset := range r.m {
		val[name] = connset.Cardinality()
	}
	r.lock.RUnlock()
	return val
}
