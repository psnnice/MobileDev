package handlers

import (
	"encoding/json"
	"net/http"
	"github.com/psnnice/MobileDev/lib/backend/database"
	"github.com/psnnice/MobileDev/lib/backend/models"
)

// RegisterHandler ฟังก์ชันสำหรับลงทะเบียนผู้ใช้
func RegisterHandler(w http.ResponseWriter, r *http.Request) {
	var user models.User
	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil || user.Username == "" || user.Password == "" {
		http.Error(w, "ข้อมูลไม่ถูกต้อง", http.StatusBadRequest)
		return
	}

	_, err = database.DB.Exec("INSERT INTO users (username, password) VALUES ($1, $2)", user.Username, user.Password)
	if err != nil {
		http.Error(w, "ไม่สามารถเพิ่มข้อมูลผู้ใช้ได้", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	w.Write([]byte("ลงทะเบียนสำเร็จ"))
}
