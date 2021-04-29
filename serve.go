package main

import (
	"flag"
	"log"
	"net/http"
)

func main() {
	port := flag.String("p", "8080", "port to serve on")
	directory := flag.String("d", ".", "the directory of static file to host")
	flag.Parse()

	// Neovim
	http.HandleFunc("/neovim", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "./static/neovim/nvim-init.sh")
	})
	// OpenCV
	http.HandleFunc("/opencv", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "./static/opencv/opencv-4.1.1-install.sh")
	})

	log.Printf("Serving %s on HTTP port: %s\n", *directory, *port)

	err := http.ListenAndServe(":"+*port, nil)
	if err != nil {
		log.Fatal(err)
	}
}
