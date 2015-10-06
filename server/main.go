package main

import (
	"net/http"

	"github.com/abesto/are-you-board/shared"

	"github.com/gin-gonic/gin"
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

	router.Run(":8080") // listen and serve on 0.0.0.0:8080
}
