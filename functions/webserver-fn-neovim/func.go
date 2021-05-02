package main

import (
	"context"
	"io"
	"log"
	"os"

	fdk "github.com/fnproject/fdk-go"
)

func main() {
	fdk.Handle(fdk.HandlerFunc(myHandler))
}

func myHandler(ctx context.Context, in io.Reader, out io.Writer) {
	// read file stream
	// file, err := os.Open("./static/opencv/opencv-4.1.1-install.sh")
	file, err := os.Open("./static/neovim/nvim-init.sh")
	if err != nil {
		log.Fatal(err)
	}

	// convert file stream to bytes
	data, e := io.ReadAll(file)
	if e != nil {
		log.Fatal(e)
	}
	// os.Stdout.Write(data)

	log.Print("Inside Go webserver function")

	// write byte output
	out.Write(data)
}
