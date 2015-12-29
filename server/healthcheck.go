package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type HealthcheckHandler func() interface{}

type Healthcheck struct {
	modules map[string]HealthcheckHandler
}

func NewHealthcheck() Healthcheck {
	return Healthcheck{map[string]HealthcheckHandler{}}
}

func (h Healthcheck) Register(name string, handler HealthcheckHandler) {
	if _, ok := h.modules[name]; ok {
		panic("Healthcheck module " + name + " already registered")
	}
	h.modules[name] = handler
}

func (h Healthcheck) HandleRequest(c *gin.Context) {
	data := map[string]interface{}{}
	for name, handler := range h.modules {
		data[name] = handler()
	}
	c.JSON(http.StatusOK, data)
}
