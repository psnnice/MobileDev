package profile

import (
	"database/sql"
	"flutter_project/pkg/utils"
	"time"

	"github.com/gofiber/fiber/v2"
)

type UserProfile struct {
	ID               int    `json:"id"`
	UserID           int    `json:"user_id"`
	ProfileImagePath string `json:"profile_image_path"`
	CreatedAt        string `json:"created_at"`
	UpdatedAt        string `json:"updated_at"`
}

// Handler สำหรับอัปโหลดรูปโปรไฟล์
func UploadProfileHandler(c *fiber.Ctx) error {
	var profile UserProfile
	if err := c.BodyParser(&profile); err != nil {
		return c.Status(fiber.StatusBadRequest).SendString("Invalid request payload: " + err.Error())
	}

	// ตรวจสอบว่าผู้ใช้มีอยู่จริง
	exists, err := checkUserExists(profile.UserID)
	if err != nil || !exists {
		return c.Status(fiber.StatusBadRequest).SendString("Invalid user_id: User does not exist")
	}

	profile.CreatedAt = time.Now().Format("2006-01-02 15:04:05")

	// ตรวจสอบว่ามีโปรไฟล์เดิมอยู่หรือไม่
	hasProfile, err := checkUserProfileExists(profile.UserID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Error checking existing profile: " + err.Error())
	}

	if hasProfile {
		// อัปเดตโปรไฟล์เดิม
		if err := UpdateProfile(utils.DB, profile); err != nil {
			return c.Status(fiber.StatusInternalServerError).SendString("Failed to update profile picture: " + err.Error())
		}
		return c.Status(fiber.StatusOK).SendString("Profile picture updated successfully!")
	} else {
		// เพิ่มโปรไฟล์ใหม่
		if err := InsertProfile(utils.DB, profile); err != nil {
			return c.Status(fiber.StatusInternalServerError).SendString("Failed to upload profile picture: " + err.Error())
		}
		return c.Status(fiber.StatusCreated).SendString("Profile picture uploaded successfully!")
	}
}

// ฟังก์ชันตรวจสอบว่าผู้ใช้มีอยู่จริงหรือไม่
func checkUserExists(userID int) (bool, error) {
	var exists bool
	err := utils.DB.QueryRow("SELECT EXISTS (SELECT 1 FROM users WHERE id = $1)", userID).Scan(&exists)
	return exists, err
}

// ฟังก์ชันตรวจสอบว่ามีโปรไฟล์เดิมอยู่หรือไม่
func checkUserProfileExists(userID int) (bool, error) {
	var exists bool
	err := utils.DB.QueryRow("SELECT EXISTS (SELECT 1 FROM public.user_profiles WHERE user_id = $1)", userID).Scan(&exists)
	return exists, err
}

// ฟังก์ชันเพิ่มโปรไฟล์ลงในฐานข้อมูล
func InsertProfile(db *sql.DB, profile UserProfile) error {
	query := `
		INSERT INTO public.user_profiles (user_id, profile_image_path, created_at, updated_at)
		VALUES ($1, $2, $3, $4)
	`
	_, err := db.Exec(query, profile.UserID, profile.ProfileImagePath, profile.CreatedAt, profile.CreatedAt)
	return err
}

// ฟังก์ชันอัปเดตโปรไฟล์เดิมในฐานข้อมูล
func UpdateProfile(db *sql.DB, profile UserProfile) error {
	query := `
		UPDATE public.user_profiles
		SET profile_image_path = $1, updated_at = $2
		WHERE user_id = $3
	`
	_, err := db.Exec(query, profile.ProfileImagePath, profile.CreatedAt, profile.UserID)
	return err
}

func GetProfile(db *sql.DB, userID int) (*UserProfile, error) {
	query := `
        SELECT id, user_id, profile_image_path, created_at, updated_at
        FROM public.user_profiles
        WHERE user_id = $1
    `
	var profile UserProfile
	err := db.QueryRow(query, userID).Scan(&profile.ID, &profile.UserID, &profile.ProfileImagePath, &profile.CreatedAt, &profile.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return &profile, nil
}

// Handler สำหรับดึงข้อมูลโปรไฟล์
func GetProfileHandler(c *fiber.Ctx) error {
	userID, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).SendString("Invalid user ID")
	}

	profile, err := GetProfile(utils.DB, userID)
	if err != nil {
		if err == sql.ErrNoRows {
			return c.Status(fiber.StatusNotFound).SendString("Profile not found")
		}
		return c.Status(fiber.StatusInternalServerError).SendString("Error retrieving profile: " + err.Error())
	}

	return c.JSON(profile)
}

func DeleteProfile(db *sql.DB, userID int) error {
	query := `
        DELETE FROM public.user_profiles
        WHERE user_id = $1
    `
	_, err := db.Exec(query, userID)
	return err
}

func DeleteProfileHandler(c *fiber.Ctx) error {
	userID, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).SendString("Invalid user ID")
	}

	err = DeleteProfile(utils.DB, userID)
	if err != nil {
		if err == sql.ErrNoRows {
			return c.Status(fiber.StatusNotFound).SendString("Profile not found")
		}
		return c.Status(fiber.StatusInternalServerError).SendString("Error deleting profile: " + err.Error())
	}

	return c.Status(fiber.StatusOK).SendString("Profile deleted successfully")
}
