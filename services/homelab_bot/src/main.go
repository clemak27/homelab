package main

import (
	"log"
	"net/http"
	"os"

	messagehandler "github.com/clemak27/homelab_bot/messageHandler"
	"github.com/gorilla/mux"
)

func main() {
	router := mux.NewRouter()
	handler := messagehandler.TelegramHandler{}
	router.HandleFunc("/message", handler.PostMessage).Methods("POST")
	router.HandleFunc("/message/silent", handler.PostSilentMessage).Methods("POST")
	http.Handle("/", router)
	log.Println("Server starting on port 8525")

	//nolint:gosec
	err := http.ListenAndServe(":8525", router)
	if err != nil {
		log.Println("could not start server!")
		log.Println(err)
		os.Exit(1)
	}
}
