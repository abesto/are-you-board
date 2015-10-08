package main

import (
	"log"
	"net/http"
	"encoding/json"

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
			messageType, p, err := conn.ReadMessage()
			if err != nil {
				log.Print(err)
				return
			}
			var in shared.ChatMessageWithoutSender
			var out shared.ChatMessage
			json.Unmarshal(p, &in)
			out.Message = in.Message
			out.Sender = "whoever"
			out.Timestamp = 3000
			var outp []byte
			outp, err = json.Marshal(out)
			if err != nil {
				log.Print(err)
				return
			}
			if err = conn.WriteMessage(messageType, outp); err != nil {
				log.Print(err)
				return
			}
		}
	})

	router.Run(":8080") // listen and serve on 0.0.0.0:8080
}
