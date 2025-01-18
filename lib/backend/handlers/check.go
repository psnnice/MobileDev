package handlers

import (
	"net/http"
	"github.com/psnnice/MobileDev/lib/backend/database"
)

// ตรวจสอบสถานะเซิร์ฟเวอร์
func HealthCheckHandler(w http.ResponseWriter, r *http.Request) {
	err := database.DB.Ping()
	if err != nil {
		http.Error(w, "ฐานข้อมูลไม่พร้อมใช้งาน", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("เซิร์ฟเวอร์พร้อมใช้งาน"))
}
