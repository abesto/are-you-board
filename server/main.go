package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"

	"github.com/abesto/are-you-board/shared"
)

func main() {
	router := gin.Default()
	router.Static("/static", "../client")
	router.LoadHTMLGlob("templates/*")

	healthcheck := NewHealthcheck()
	router.GET("/healthcheck", healthcheck.HandleRequest)

	router.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.html", gin.H{
			"title": "Main website",
		})
	})

	socketRegistry := NewSocketRegistry()
	healthcheck.Register("websocketRegistry", func() interface{} {
		data := map[string]interface{}{}
		data["connectionCount"] = socketRegistry.ConnectionCount()
		return data
	})

	wsHandlers := NewWSHandlerRegistry()
	healthcheck.Register("wsHandlerRegistry", func() interface{} {
		data := map[string]interface{}{}
		data["registeredHandlers"] = wsHandlers.HandlerNames()
		return data
	})

	wsHandlers.Register("Ohai", func(data []byte, session WSSession, socketRegistry SocketRegistry) (error, *websocket.Conn) {
		var ohai shared.Ohai
		mustUnmarshal(data, &ohai)
		socketRegistry.Add("ChatMessage", session.Conn)
		session.Nickname = ohai.Nickname
		log.Printf("joined: %s", session.Nickname)
		return socketRegistry.WriteJson("ChatMessage", shared.ChatMessage{
			Sender:    "system",
			Timestamp: (int)(time.Now().Unix()),
			Message:   session.Nickname + " joined",
		})
	})

	wsHandlers.Register("ChatMessage", func(data []byte, session WSSession, socketRegistry SocketRegistry) (error, *websocket.Conn) {
		var in shared.ChatMessageWithoutSender
		mustUnmarshal(data, &in)
		out := shared.ChatMessage{
			Message:   in.Message,
			Sender:    session.Nickname,
			Timestamp: (int)(time.Now().Unix()),
		}
		err, failedConn := socketRegistry.WriteJson("ChatMessage", out)
		if err != nil {
			socketRegistry.Remove("ChatMessage", failedConn)
		}
		return err, failedConn
	})

	router.GET("/ws", func(c *gin.Context) {
		conn, err := websocket.Upgrade(c.Writer, c.Request, nil, 1024, 1024)
		if err != nil {
			panic(err)
		}

		// TODO: detach here from the gin request serving goroutine

		session := WSSession{Conn: conn}

		for {
			_, p, err := conn.ReadMessage()
			if err != nil {
				panic(err)
			}

			var envelope shared.WSEnvelope
			err = json.Unmarshal(p, &envelope)
			if err != nil {
				panic(err)
			}
			log.Printf("Received %s", envelope)

			wsHandlers.Get(envelope.Name)(envelope.Content, session, socketRegistry)
		}
	})

	router.Run("127.0.0.1:" + getPort())
}

func getPort() string {
	portFromEnv, portSetInEnv := os.LookupEnv("PORT")
	if portSetInEnv {
		return portFromEnv
	}
	return "8080"
}

func mustUnmarshal(data []byte, obj interface{}) {
	if err := json.Unmarshal(data, &obj); err != nil {
		panic(err)
	}
}
