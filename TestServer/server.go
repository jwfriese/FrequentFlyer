package main

import (
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/errorplease", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(`{"error" : "here it is"}`))
	})
	http.HandleFunc("/successyeah", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"success" : "yeah" }`))
	})

	log.Fatal(http.ListenAndServe(":8181", nil))
}
