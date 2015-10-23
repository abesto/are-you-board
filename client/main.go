package main

import (
	"bytes"
	"encoding/json"
	"html/template"
	"log"

	"github.com/gopherjs/jquery"
	"github.com/gopherjs/websocket"
	"honnef.co/go/js/dom"

	"github.com/abesto/are-you-board/shared"
)

var conn *websocket.Conn

func write(obj interface{}) (int, error) {
	buf, err := json.Marshal(obj)
	if err != nil {
		return -1, err
	}
	return conn.WriteString(string(buf))
}

func read(into interface{}) error {
	bufsize := 1024
	buf := make([]byte, bufsize)
	var content []byte
	var err error
	n := 0
	for {
		n, err = conn.Read(buf)
		if err != nil {
			return err
		}
		content = append(content, buf[:n]...)
		if n < bufsize {
			break
		}
	}
	return json.Unmarshal(content, &into)
}

func main() {
	var err error
	conn, err = websocket.Dial("ws://localhost:8080/ws/chat")
	if err != nil {
		log.Print("Failed to connect to websocket server")
		log.Print(err)
		return
	}

	window := dom.GetWindow()
	nickname := window.Prompt("Nickname", "")

	if err != nil {
		handleError(err)
	}

	write(shared.Ohai{Nickname: nickname})

	const historyItemHTML = `
<tr>
  <td>{{.Timestamp}}</td>
  <td>{{.Sender}}</td>
  <td>{{.Message}}</td>
</tr>
`
	historyItemTpl := template.Must(template.New("HistoryItem").Parse(historyItemHTML))

	var jQuery = jquery.NewJQuery

	go func() {
		var msg shared.ChatMessage
		for {
			err = read(&msg)
			if err != nil {
				handleError(err)
				break
			}

			var b bytes.Buffer
			historyItemTpl.Execute(&b, msg)
			html := b.String()

			jQuery("#history").Append(html)
			log.Print(msg)

		}
	}()

	jQuery("#send-form").Submit(func() bool {
		msg := jQuery("#msg").Val()
		jQuery("#msg").SetVal("")
		write(shared.ChatMessageWithoutSender{Message: msg})
		return false
	})
}

func handleError(err error) {
	log.Print(err)
}
