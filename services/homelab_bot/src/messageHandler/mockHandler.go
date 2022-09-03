package messagehandler

import (
	"encoding/json"
	"log"
	"net/http"
)

type MockHandler struct{}

func (h *MockHandler) PostMessage(w http.ResponseWriter, req *http.Request) {
	log.Println("handling message")
	w.Header().Set("content-type", "application/json")

	var msg Message
	_ = json.NewDecoder(req.Body).Decode(&msg)
	log.Printf("sending message with text %v\n", msg.Text)
}

func (h *MockHandler) PostSilentMessage(w http.ResponseWriter, req *http.Request) {
	log.Println("handling message")
	w.Header().Set("content-type", "application/json")

	var msg Message
	_ = json.NewDecoder(req.Body).Decode(&msg)
	log.Printf("sending message with text %v\n", msg.Text)
}
