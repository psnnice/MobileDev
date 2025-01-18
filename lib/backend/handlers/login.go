package handlers

import (
	"encoding/json"
	"net/http"
	"github.com/psnnice/MobileDev/lib/backend/database"
	"github.com/psnnice/MobileDev/lib/backend/models"
)

// LoginHandler ฟังก์ชันสำหรับล็อกอิน
func LoginHandler(w http.ResponseWriter, r *http.Request) {
	var user models.User
	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil || user.Username == "" || user.Password == "" {
		http.Error(w, "ข้อมูลไม่ถูกต้อง", http.StatusBadRequest)
		return
	}

	var storedPassword string
	err = database.DB.QueryRow("SELECT password FROM users WHERE username=$1", user.Username).Scan(&storedPassword)
	if err != nil || storedPassword != user.Password {
		http.Error(w, "ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง", http.StatusUnauthorized)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("เข้าสู่ระบบสำเร็จ"))
}
