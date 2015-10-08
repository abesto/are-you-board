package main

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"

	"github.com/abesto/are-you-board/shared"
)

func main() {
	router := gin.Default()
	router.Static("/static", "../client")
	router.LoadHTMLGlob("templates/*")

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

	router.GET("/ws/chat", func(c *gin.Context) {
		conn, err := websocket.Upgrade(c.Writer, c.Request, nil, 1024, 1024)
		if err != nil {
			panic(err)
		}
		for {
			var in shared.ChatMessageWithoutSender
			var out shared.ChatMessage
			err := read(conn, &in)
			if err != nil {
				log.Print(err)
				return
			}
			out.Message = in.Message
			out.Sender = "whoever"
			out.Timestamp = 3000
			write(conn, out)
		}
	})

	router.Run(":8080") // listen and serve on 0.0.0.0:8080
}

func read(conn *websocket.Conn, obj interface{}) error {
	_, p, err := conn.ReadMessage()
	if err != nil {
		log.Print(err)
		return err
	}
	json.Unmarshal(p, obj)
	return nil

}

func write(conn *websocket.Conn, obj interface{}) {
	outp, err := json.Marshal(obj)
	if err != nil {
		log.Print(err)
		return
	}
	if err = conn.WriteMessage(websocket.TextMessage, outp); err != nil {
		log.Print(err)
		return
	}

}
