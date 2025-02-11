package bus

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"flutter_project/pkg/utils"

	"github.com/gofiber/fiber/v2"
)

type DeviceData struct {
	ID          int       `json:"id"`
	DeviceID    string    `json:"device_id"`
	Latitude    float64   `json:"latitude"`
	Longitude   float64   `json:"longitude"`
	DeviceCount int       `json:"device_count"`
	Timestamp   time.Time `json:"timestamp"`
	UserID      int       `json:"user_id"` // เพิ่ม user_id
}

func InsertDeviceDataHandler(c *fiber.Ctx) error {
	var deviceDataList []DeviceData
	if err := c.BodyParser(&deviceDataList); err != nil {
		log.Println("Invalid request payload:", err)
		return c.Status(http.StatusBadRequest).SendString("Invalid request payload: " + err.Error())
	}

	for _, deviceData := range deviceDataList {
		var err error
		deviceData.Timestamp, err = time.Parse(time.RFC3339, deviceData.Timestamp.Format(time.RFC3339))
		if err != nil {
			log.Println("Invalid timestamp format:", err)
			return c.Status(http.StatusBadRequest).SendString("Invalid timestamp format: " + err.Error())
		}

		// ตรวจสอบว่าผู้ใช้มีอยู่จริงหรือไม่
		exists, err := checkUserExists(deviceData.UserID)
		if err != nil {
			log.Println("Error checking user existence:", err)
			return c.Status(http.StatusInternalServerError).SendString("Error checking user existence: " + err.Error())
		}
		if !exists {
			log.Println("Invalid user_id:", deviceData.UserID)
			return c.Status(http.StatusBadRequest).SendString("Invalid user_id: User does not exist")
		}

		if err := InsertDeviceData(deviceData); err != nil {
			log.Println("Failed to insert data:", err)
			return c.Status(http.StatusInternalServerError).SendString("Failed to insert data: " + err.Error())
		}
	}

	return c.SendString("Data inserted successfully")
}

func InsertDeviceData(deviceData DeviceData) error {
	if utils.DB == nil {
		return fmt.Errorf("database connection is not initialized")
	}

	_, err := utils.DB.Exec(`
        INSERT INTO device_data (device_id, latitude, longitude, device_count, timestamp, user_id)
        VALUES ($1, $2, $3, $4, $5, $6)
        ON CONFLICT (device_id) DO UPDATE
        SET latitude = EXCLUDED.latitude,
            longitude = EXCLUDED.longitude,
            device_count = EXCLUDED.device_count,
            timestamp = EXCLUDED.timestamp,
            user_id = EXCLUDED.user_id`,
		deviceData.DeviceID, deviceData.Latitude, deviceData.Longitude, deviceData.DeviceCount, deviceData.Timestamp, deviceData.UserID)

	if err != nil {
		log.Println("Database Insert Error:", err) // 👉 เพิ่ม log ตรวจสอบข้อผิดพลาด
		return err
	}
	return nil
}

func GetDeviceDataHandler(c *fiber.Ctx) error {
	if utils.DB == nil {
		return c.Status(500).SendString("การเชื่อมต่อฐานข้อมูลยังไม่ถูกตั้งค่า")
	}

	rows, err := utils.DB.Query("SELECT id, device_id, latitude, longitude, device_count, timestamp, user_id FROM device_data")
	if err != nil {
		return c.Status(500).SendString("เกิดข้อผิดพลาดในการดึงข้อมูลจากฐานข้อมูล: " + err.Error())
	}
	defer rows.Close()

	var devices []DeviceData
	for rows.Next() {
		var device DeviceData
		if err := rows.Scan(&device.ID, &device.DeviceID, &device.Latitude, &device.Longitude, &device.DeviceCount, &device.Timestamp, &device.UserID); err != nil {
			return c.Status(http.StatusInternalServerError).SendString("เกิดข้อผิดพลาดในการสแกนข้อมูล: " + err.Error())
		}
		devices = append(devices, device)
	}

	deviceDataJSON, err := json.Marshal(devices)
	if err != nil {
		return c.Status(http.StatusInternalServerError).SendString("เกิดข้อผิดพลาดในการแปลงข้อมูลเป็น JSON: " + err.Error())
	}

	return c.Status(http.StatusOK).Send(deviceDataJSON)
}

// ฟังก์ชันตรวจสอบว่าผู้ใช้มีอยู่จริงหรือไม่
func checkUserExists(userID int) (bool, error) {
	var exists bool
	err := utils.DB.QueryRow("SELECT EXISTS (SELECT 1 FROM users WHERE id = $1)", userID).Scan(&exists)
	return exists, err
}
