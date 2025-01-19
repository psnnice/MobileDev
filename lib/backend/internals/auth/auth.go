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

	// แฮชรหัสผ่าน
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Failed to hash password")
	}

	// บันทึกข้อมูลลงฐานข้อมูล
	_, err = utils.DB.Exec("INSERT INTO users (username, password) VALUES ($1, $2)", user.Username, string(hashedPassword))
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

	// ดึงรหัสผ่านที่แฮชจากฐานข้อมูล
	var storedHashedPassword string
	err := utils.DB.QueryRow("SELECT password FROM users WHERE username=$1", user.Username).Scan(&storedHashedPassword)
	if err == sql.ErrNoRows {
		return c.Status(fiber.StatusUnauthorized).SendString("Invalid username or password")
	} else if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Error authenticating user")
	}

	// เปรียบเทียบรหัสผ่าน
	err = bcrypt.CompareHashAndPassword([]byte(storedHashedPassword), []byte(user.Password))
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).SendString("Invalid username or password")
	}

	// สร้าง JWT Token
	token, err := utils.GenerateToken(user.Username)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Failed to generate token")
	}

	return c.JSON(fiber.Map{"token": token})
}
