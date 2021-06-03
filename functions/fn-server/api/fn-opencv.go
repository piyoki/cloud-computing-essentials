package handler

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
)

func Handler(w http.ResponseWriter, r *http.Request) {

	// read file stream
	file, err := os.Open("scripts/opencv-4.1.1-install.sh")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	// convert file stream to bytes
	data, e := io.ReadAll(file)
	if e != nil {
		log.Fatal(e)
	}
	log.Print("Inside Go webserver function")
	fmt.Fprintf(w, string(data))
}
