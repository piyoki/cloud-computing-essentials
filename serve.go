package main

import (
	"github.com/gin-gonic/gin"
)

func main() {
	// instantiate the server
	router := gin.Default()

	// define routes
	router.GET("/neovim", func(c *gin.Context) {
		c.File("./static/neovim/nvim-init.sh")
	})
	router.GET("/opencv", func(c *gin.Context) {
		c.File("./static/opencv/opencv-4.1.1-install.sh")
	})

	// Listen and serve on 0.0.0.0:8080
	router.Run(":8080")
}
