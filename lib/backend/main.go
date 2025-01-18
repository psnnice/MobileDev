package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/psnnice/MobileDev/lib/backend/database"
	"github.com/psnnice/MobileDev/lib/backend/handlers"
)

func main() {

	database.InitDB()
	defer database.CloseDB()

	// Router
	r := mux.NewRouter()
	r.HandleFunc("/register", handlers.RegisterHandler).Methods("POST")
	r.HandleFunc("/login", handlers.LoginHandler).Methods("POST")
	r.HandleFunc("/check", handlers.HealthCheckHandler).Methods("GET")

	log.Println("Server is running on port 8080")
	log.Fatal(http.ListenAndServe(":8080", r))
}
