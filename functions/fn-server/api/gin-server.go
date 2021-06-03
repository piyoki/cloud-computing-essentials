package handler

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	// "os/exec"
)

func Handler(w http.ResponseWriter, r *http.Request) {
	// out, err := exec.Command("ls", "-ltr", "api").Output()
	// if err != nil {
	//   fmt.Printf("%s", err)
	// }
	// fmt.Println("Command Successfully Executed")
	// output := string(out[:])
	// fmt.Println(output)

	// read file stream
	file, err := os.Open("scripts/neovim.sh")
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
