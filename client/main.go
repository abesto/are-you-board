package main

import (
	"bytes"
	"html/template"

	"honnef.co/go/js/dom"
)

func main() {
	if wsConnect() != nil {
		return
	}

	tplHistoryItem := newTpl("HistoryItem", `
<tr>
	<td>{{.Timestamp}}</td>
  <td>{{.Sender}}</td>
  <td>{{.Message}}</td>
</tr>
`)

	window := dom.GetWindow()
	nickname := window.Prompt("Nickname", "")

	chat := newChat(chatOpts{
		tplHistoryItem:  tplHistoryItem,
		historySelector: "#history",
		formSelector:    "#send-form",
		inputSelector:   "#msg",
		sendSelector:    "#send",
	})

	chat.connect(nickname)
}

type tpl struct {
	parsed *template.Template
}

func newTpl(name string, rawTpl string) *tpl {
	t := tpl{
		parsed: template.Must(template.New(name).Parse(rawTpl)),
	}
	return &t
}

func (t *tpl) render(data interface{}) string {
	var b bytes.Buffer
	t.parsed.Execute(&b, data)
	return b.String()
}
