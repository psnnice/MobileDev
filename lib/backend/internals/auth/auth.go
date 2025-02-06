package auth

import (
	"database/sql"
	"flutter_project/pkg/utils"

	"github.com/gofiber/fiber/v2"
	"golang.org/x/crypto/bcrypt"
)

type User struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

func RegisterHandler(c *fiber.Ctx) error {
	var user User
	if err := c.BodyParser(&user); err != nil {
		return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
	}

	if user.Username == "" || user.Password == "" {
		return c.Status(fiber.StatusBadRequest).SendString("Username and password are required")
	}

	// ตรวจสอบว่ามี username นี้อยู่แล้วหรือไม่
	var exists bool
	err := utils.DB.QueryRow("SELECT EXISTS (SELECT 1 FROM users WHERE username=$1)", user.Username).Scan(&exists)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Database error")
	}

	if exists {
		return c.Status(409).SendString("Username already exists")
	}

	// แฮชรหัสผ่าน
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Failed to hash password")
	}

	// บันทึกข้อมูลลงฐานข้อมูล
	_, err = utils.DB.Exec("INSERT INTO users (username, password, role) VALUES ($1, $2, $3)", user.Username, string(hashedPassword), "user")
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Failed to register user")
	}

	return c.Status(fiber.StatusCreated).SendString("User registered successfully")
}

func LoginHandler(c *fiber.Ctx) error {
	var user User
	if err := c.BodyParser(&user); err != nil {
		return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
	}

	if user.Username == "" || user.Password == "" {
		return c.Status(fiber.StatusBadRequest).SendString("Username and password are required")
	}

	// ดึงรหัสผ่านที่แฮชและ role จากฐานข้อมูล
	var storedHashedPassword, role string
	var userID int
	err := utils.DB.QueryRow("SELECT id, password, role FROM users WHERE username=$1", user.Username).Scan(&userID, &storedHashedPassword, &role)
	if err == sql.ErrNoRows {
		return c.Status(fiber.StatusUnauthorized).SendString("Invalid username or password")
	} else if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Database error")
	}

	// เปรียบเทียบรหัสผ่าน
	err = bcrypt.CompareHashAndPassword([]byte(storedHashedPassword), []byte(user.Password))
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).SendString("Invalid username or password")
	}

	// สร้าง JWT Token พร้อม role
	token, err := utils.GenerateToken(user.Username, role)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Failed to generate token")
	}

	return c.JSON(fiber.Map{
		"token":    token,
		"role":     role,
		"username": user.Username,
		"id":       userID,
	})
}
