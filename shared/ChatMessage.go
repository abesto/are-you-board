package shared

// ChatMessageWithoutSender is sent by clients to the server
type ChatMessageWithoutSender struct {
	Message string `json:"msg"`
}

// ChatMessage is sent by the server to the clients
type ChatMessage struct {
	ChatMessageWithoutSender
	Sender string `json:"sender"`
	Timestamp int `json:"timestamp"`
}
