package utils

import (
	"database/sql"
	"log"
	"os"

	_ "github.com/lib/pq"
)

var DB *sql.DB

// เชื่อมต่อฐานข้อมูล
func InitDB() {
	var err error
	connStr := "user=" + os.Getenv("DB_USER") +
		" password=" + os.Getenv("DB_PASSWORD") +
		" dbname=" + os.Getenv("DB_NAME") +
		" host=" + os.Getenv("DB_HOST") +
		" port=" + os.Getenv("DB_PORT") +
		" sslmode=" + os.Getenv("DB_SSLMODE")

	DB, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("เชื่อม DATABASE ไม่ได้:", err)
	}

	err = DB.Ping()
	if err != nil {
		log.Fatal("DATABASE ไม่พร้อมใช้งาน:", err)
	}
	log.Println("เชื่อม DATABASE สำเร็จ")
}

// ปิดการเชื่อมต่อฐานข้อมูล
func CloseDB() {
	DB.Close()
}
