package main

import "fmt"
import "os"
import "log"
import "github.com/joho/godotenv"

func main() {
	godotenv.Overload(".env")

	portString := os.Getenv("PORT")
	if portString == "" {
		log.Fatal("Failed to read PORT env var")
	}

	fmt.Println("Port: ", portString)

}
