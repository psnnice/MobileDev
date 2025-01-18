package database

import (
	"database/sql"
	"log"
	"os"

	_ "github.com/lib/pq"
)

var DB *sql.DB

func InitDB() {
	var err error
	connStr := "user=" + os.Getenv("DB_USER") +
		" password=" + os.Getenv("DB_PASSWORD") +
		" dbname=" + os.Getenv("DB_NAME") +
		" host=" + os.Getenv("DB_HOST") +
		" port=" + os.Getenv("DB_PORT") +
		" sslmode=disable"
	DB, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("Failed to connect to the database:", err)
	}

	err = DB.Ping()
	if err != nil {
		log.Fatal("Failed to ping the database:", err)
	}
	log.Println("Connected to the database successfully")
}

// ปิดการเชื่อมต่อฐานข้อมูล
func CloseDB() {
	if DB != nil {
		DB.Close()
	}
}
