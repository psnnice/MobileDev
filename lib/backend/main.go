package main

import (
	"database/sql"
	"encoding/json"
	"log"
	"net/http"

	"github.com/gorilla/mux"
	_ "github.com/lib/pq"
)

var db *sql.DB

// initDB เชื่อมต่อกับฐานข้อมูล
func initDB() {
	var err error
	connStr := "user=postgres password=7278387599 dbname=postgres sslmode=disable"
	db, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatalf("ไม่สามารถเชื่อมต่อฐานข้อมูลได้: %v", err)
	}

	err = db.Ping()
	if err != nil {
		log.Fatalf("ไม่สามารถเข้าถึงฐานข้อมูลได้: %v", err)
	}
	log.Println("เชื่อมต่อฐานข้อมูลสำเร็จ")
}

type User struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

// registerHandler ฟังก์ชันสำหรับการลงทะเบียน
func registerHandler(w http.ResponseWriter, r *http.Request) {
	var user User
	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil || user.Username == "" || user.Password == "" {
		http.Error(w, "ข้อมูลไม่ถูกต้อง", http.StatusBadRequest)
		log.Printf("ข้อผิดพลาด: การรับข้อมูลลงทะเบียนไม่ถูกต้อง: %v", err)
		return
	}

	_, err = db.Exec("INSERT INTO users (username, password) VALUES ($1, $2)", user.Username, user.Password)
	if err != nil {
		http.Error(w, "ไม่สามารถเพิ่มข้อมูลผู้ใช้ได้", http.StatusInternalServerError)
		log.Printf("ข้อผิดพลาด: การเพิ่มข้อมูลผู้ใช้: %v", err)
		return
	}

	log.Printf("ลงทะเบียนสำเร็จ: %s", user.Username)
	w.WriteHeader(http.StatusCreated)
	w.Write([]byte("ลงทะเบียนสำเร็จ"))
}

// loginHandler ฟังก์ชันสำหรับการเข้าสู่ระบบ
func loginHandler(w http.ResponseWriter, r *http.Request) {
	var user User
	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil || user.Username == "" || user.Password == "" {
		http.Error(w, "ข้อมูลไม่ถูกต้อง", http.StatusBadRequest)
		log.Printf("ข้อผิดพลาด: การรับข้อมูลเข้าสู่ระบบไม่ถูกต้อง: %v", err)
		return
	}

	var storedPassword string
	err = db.QueryRow("SELECT password FROM users WHERE username=$1", user.Username).Scan(&storedPassword)
	if err == sql.ErrNoRows || storedPassword != user.Password {
		http.Error(w, "ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง", http.StatusUnauthorized)
		log.Printf("การเข้าสู่ระบบล้มเหลว: %s", user.Username)
		return
	} else if err != nil {
		http.Error(w, "เกิดข้อผิดพลาดในการตรวจสอบผู้ใช้", http.StatusInternalServerError)
		log.Printf("ข้อผิดพลาด: การตรวจสอบข้อมูลผู้ใช้: %v", err)
		return
	}

	log.Printf("เข้าสู่ระบบสำเร็จ: %s", user.Username)
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("เข้าสู่ระบบสำเร็จ"))
}

// healthCheckHandler ฟังก์ชันสำหรับตรวจสอบสถานะเซิร์ฟเวอร์
func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
	err := db.Ping()
	if err != nil {
		http.Error(w, "ฐานข้อมูลไม่พร้อมใช้งาน", http.StatusInternalServerError)
		log.Printf("ข้อผิดพลาด: การตรวจสอบฐานข้อมูล: %v", err)
		return
	}

	log.Println("เซิร์ฟเวอร์พร้อมใช้งาน")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("เซิร์ฟเวอร์พร้อมใช้งาน"))
}

func main() {
	initDB()
	defer func() {
		if err := db.Close(); err != nil {
			log.Printf("ข้อผิดพลาด: ไม่สามารถปิดการเชื่อมต่อฐานข้อมูล: %v", err)
		}
	}()

	r := mux.NewRouter()
	r.HandleFunc("/register", registerHandler).Methods("POST")
	r.HandleFunc("/login", loginHandler).Methods("POST")
	r.HandleFunc("/health", healthCheckHandler).Methods("GET")

	log.Println("เซิร์ฟเวอร์กำลังทำงานบนพอร์ต 8080")
	log.Fatal(http.ListenAndServe(":8080", r))
}
