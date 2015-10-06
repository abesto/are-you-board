package main

import (
	"net/http"
	
	"github.com/abesto/are-you-board/shared"

	"github.com/gin-gonic/gin"
)

var socketioServer *socketio.Server

func main() {
	var err error
	r := gin.Default()
	if err != nil {
		panic(err)
	}

	r.GET("/ping", func(c *gin.Context) {
		c.String(200, "pong")
	})

	r.GET("/msg", func(c *gin.Context) {
		msg := ChatMessage{Message: "message", Sender: "sender", Timestamp: 30}
		c.JSON(http.StatusOK, msg)
	})
	
	r.Run(":8080") // listen and serve on 0.0.0.0:8080
}
