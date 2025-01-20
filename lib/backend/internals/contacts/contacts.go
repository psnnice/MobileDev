package contacts

import (
	"database/sql"
	"flutter_project/pkg/utils"
	"github.com/gofiber/fiber/v2"
)

type Contact struct {
	ID           int    `json:"id"`
	ImagePath    string `json:"imagePath"`
	ProfileImage string `json:"profileImage"`
	Title        string `json:"title"`
	Email        string `json:"email"`
	PhoneNumber  string `json:"phoneNumber"`
	URL          string `json:"url"`
	CreatedAt    string `json:"createdAt"`
}

// Handler สำหรับดึง Contact ทั้งหมด
func GetContactHandler(c *fiber.Ctx) error {
	contactList, err := GetAllContacts() // เรียกใช้ฟังก์ชัน GetAllContacts
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Failed to fetch contacts")
	}

	return c.JSON(contactList) // ส่งผลลัพธ์ในรูปแบบ JSON
}

// ดึง Contact ทั้งหมดจากฐานข้อมูล
func GetAllContacts() ([]Contact, error) {
	rows, err := utils.DB.Query("SELECT id, image_path, profile_image, title, email, phone_number, url, created_at FROM contacts")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var contactList []Contact
	for rows.Next() {
		var (
			id           int
			imagePath    sql.NullString
			profileImage sql.NullString
			title        sql.NullString
			email        sql.NullString
			phoneNumber  sql.NullString
			url          sql.NullString
			createdAt    sql.NullString
		)

		err := rows.Scan(&id, &imagePath, &profileImage, &title, &email, &phoneNumber, &url, &createdAt)
		if err != nil {
			return nil, err
		}

		contact := Contact{
			ID:           id,
			ImagePath:    nullableStringToDefault(imagePath),
			ProfileImage: nullableStringToDefault(profileImage),
			Title:        nullableStringToDefault(title),
			Email:        nullableStringToDefault(email),
			PhoneNumber:  nullableStringToDefault(phoneNumber),
			URL:          nullableStringToDefault(url),
			CreatedAt:    nullableStringToDefault(createdAt),
		}

		contactList = append(contactList, contact)
	}

	// ตรวจสอบ error ระหว่างการอ่านข้อมูล
	if err = rows.Err(); err != nil {
		return nil, err
	}

	return contactList, nil
}

// Helper ฟังก์ชันสำหรับจัดการ NullString
func nullableStringToDefault(ns sql.NullString) string {
	if ns.Valid {
		return ns.String
	}
	return "" // คืนค่าเป็นช่องว่างหาก NULL
}
