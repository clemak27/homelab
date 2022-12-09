package messagehandler

import "net/http"

type Message struct {
	Title string `json:"title,omitempty"`
	Text  string `json:"text,omitempty"`
}

type MessageHandler interface {
	PostMessage(w http.ResponseWriter, req *http.Request)
	Healthcheck(w http.ResponseWriter, req *http.Request)
}
