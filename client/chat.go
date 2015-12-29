package main

import (
	"encoding/json"
	"log"

	"github.com/gopherjs/jquery"

	"github.com/abesto/are-you-board/shared"
)

type chat struct {
	history        jquery.JQuery
	form           jquery.JQuery
	input          jquery.JQuery
	send           jquery.JQuery
	tplHistoryItem *tpl
}

type chatOpts struct {
	historySelector string
	formSelector    string
	inputSelector   string
	sendSelector    string
	tplHistoryItem  *tpl
}

func newChat(opts chatOpts) *chat {
	jQuery := jquery.NewJQuery
	c := chat{
		tplHistoryItem: opts.tplHistoryItem,
		history:        jQuery(opts.historySelector),
		form:           jQuery(opts.formSelector),
		input:          jQuery(opts.inputSelector),
		send:           jQuery(opts.sendSelector),
	}
	return &c
}

func (c *chat) connect(nickname string) {
	wsWrite("Ohai", shared.Ohai{Nickname: nickname})
	c.listen()
	c.form.Submit(func() bool {
		msg := c.input.Val()
		c.input.SetVal("")
		wsWrite("ChatMessage", shared.ChatMessageWithoutSender{Message: msg})
		return false
	})
}

func (c *chat) listen() {
	wsOn("ChatMessage", func(data []byte) {
		var msg shared.ChatMessage
		err := json.Unmarshal(data, &msg)
		if err != nil {
			log.Fatal(err)
			return
		}
		c.history.Append(c.tplHistoryItem.render(msg))
		log.Print(msg)
	})
}
