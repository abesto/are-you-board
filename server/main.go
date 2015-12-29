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

	router.GET("/ping", func(c *gin.Context) {
		c.String(200, "pong")
	})

	router.GET("/msg", func(c *gin.Context) {
		msg := shared.ChatMessage{Message: "message", Sender: "sender", Timestamp: 30}
		c.JSON(http.StatusOK, msg)
	})

	socketRegistry := NewSocketRegistry()
	healthcheck.Register("websocketRegistry", func() interface{} {
		data := map[string]int{}
		data["connectionCount"] = socketRegistry.ConnectionCount()
		return data
	})

	router.GET("/ws/chat", func(c *gin.Context) {
		var failedConn *websocket.Conn
		conn, err := websocket.Upgrade(c.Writer, c.Request, nil, 1024, 1024)
		if err != nil {
			panic(err)
		}
		socketRegistry.Add("chat", conn)
		var ohai shared.Ohai
		if err = read(conn, &ohai); err != nil {
			return
		}
		socketRegistry.WriteJson("chat", shared.ChatMessage{
			Sender:    "system",
			Timestamp: (int)(time.Now().Unix()),
			Message:   ohai.Nickname + " joined",
		})
		log.Printf("joined: %s", ohai.Nickname)
		for {
			var in shared.ChatMessageWithoutSender
			var out shared.ChatMessage
			err := read(conn, &in)
			if err != nil {
				log.Print(err)
				socketRegistry.Remove("chat", conn)
				return
			}
			out.Message = in.Message
			out.Sender = ohai.Nickname
			out.Timestamp = (int)(time.Now().Unix())
			if err, failedConn = socketRegistry.WriteJson("chat", out); err != nil {
				socketRegistry.Remove("chat", failedConn)
				log.Print(err)
			}
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

func read(conn *websocket.Conn, obj interface{}) error {
	_, p, err := conn.ReadMessage()
	if err != nil {
		log.Print(err)
		return err
	}
	var envelope shared.WSEnvelope
	json.Unmarshal(p, &envelope)
	log.Print(envelope)
	// TODO here will come routing by Envelope.Name
	json.Unmarshal(envelope.Content, &obj)
	log.Print(obj)
	return nil
}
