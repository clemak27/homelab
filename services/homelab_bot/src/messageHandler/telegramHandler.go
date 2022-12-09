package messagehandler

import (
	"bytes"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strconv"
)

type TelegramHandler struct{}

// Create a struct to conform to the JSON body
// of the send message request
// https://core.telegram.org/bots/api#sendmessage
type sendMessageReqBody struct {
	ChatID    int64  `json:"chat_id"`
	ParseMode string `json:"parse_mode"`
	Text      string `json:"text"`
	Silent    bool   `json:"disable_notification,omitempty"`
}

func (h *TelegramHandler) PostMessage(w http.ResponseWriter, req *http.Request) {
	sendMessage(w, req, true)
}

func (h *TelegramHandler) PostSilentMessage(w http.ResponseWriter, req *http.Request) {
	sendMessage(w, req, false)
}

func sendMessage(w http.ResponseWriter, req *http.Request, sendNotification bool) {
	log.Println("handling message")
	w.Header().Set("content-type", "application/json")

	var (
		cis = os.Getenv("TELEGRAM_CHAT")
		url = os.Getenv("TELEGRAM_URL")
	)

	var msg Message
	_ = json.NewDecoder(req.Body).Decode(&msg)

	base := 10
	bitSize := 64

	chatID, err := strconv.ParseInt(cis, base, bitSize)
	if err != nil {
		log.Println("could not get telegram chat id")

		return
	}

	msgBody := "<b>" + msg.Title + "</b>\n" + msg.Text

	// Create the request body struct
	reqBody := &sendMessageReqBody{
		ChatID:    chatID,
		ParseMode: "HTML",
		Text:      msgBody,
		Silent:    !sendNotification,
	}

	// Create the JSON body from the struct
	reqBytes, err := json.Marshal(reqBody)
	if err != nil {
		log.Println("marshaling failed")

		return
	}

	// Send a post request with your token
	log.Println(bytes.NewBuffer(reqBytes))

	//nolint:gosec,noctx
	res, err := http.Post(url, "application/json", bytes.NewBuffer(reqBytes))
	if err != nil {
		log.Println("request failed")

		return
	}
	defer res.Body.Close()

	if res.StatusCode != http.StatusOK {
		log.Println("request failed, status not OK")

		return
	}
}

func (h *TelegramHandler) Healthcheck(w http.ResponseWriter, req *http.Request) {
	w.WriteHeader(http.StatusOK)
}
