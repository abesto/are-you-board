package shared

// ChatMessageWithoutSender is sent by clients to the server
type ChatMessageWithoutSender struct {
	Message string `json:"msg"`
}

// ChatMessage is sent by the server to the clients
type ChatMessage struct {
	Message   string `json:"msg"`
	Sender    string `json:"sender"`
	Timestamp int    `json:"timestamp"`
}

type Ohai struct {
	Nickname string `json:"nick"`
}

type WSEnvelope struct {
	Name    string
	Content []byte
}
