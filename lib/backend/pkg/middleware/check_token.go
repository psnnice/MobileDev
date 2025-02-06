package middleware

import (
	"flutter_project/pkg/utils"
	"net/http"

	"github.com/gofiber/fiber/v2"
)

func CheckToken(c *fiber.Ctx) error {
	token := c.Get("Authorization")
	if token == "" {
		return c.Status(http.StatusUnauthorized).SendString("Missing token")
	}

	// Remove "Bearer " prefix if present
	if len(token) > 7 && token[:7] == "Bearer " {
		token = token[7:]
	}

	// Validate the token
	userData, err := utils.ValidateToken(token)
	if err != nil {
		return c.Status(http.StatusUnauthorized).SendString("Invalid token")
	}

	// คุณสามารถใช้ข้อมูลผู้ใช้จาก userData ได้ที่นี่
	c.Locals("user", userData)

	return c.Next()
}
