package middleware

import (
	"flutter_project/pkg/utils"
	"net/http"

	"github.com/gofiber/fiber/v2"
)

func CheckToken(c *fiber.Ctx) error {
	token := c.Get("Authorization")
	if token == "" {
		return c.Status(http.StatusUnauthorized).JSON(fiber.Map{
			"error": "Missing token",
		})
	}

	// ตรวจสอบว่ามี "Bearer " หรือไม่ และลบออก
	if len(token) > 7 && token[:7] == "Bearer " {
		token = token[7:]
	}

	// ถ้า token หลังจากตัด "Bearer " ออกไปแล้วว่างเปล่า ให้ reject request
	if token == "" {
		return c.Status(http.StatusUnauthorized).JSON(fiber.Map{
			"error": "Token is empty",
		})
	}

	// Validate the token
	userData, err := utils.ValidateToken(token)
	if err != nil {
		return c.Status(http.StatusUnauthorized).JSON(fiber.Map{
			"error": "Invalid token",
		})
	}

	// ตรวจสอบว่าข้อมูล userData ไม่เป็น nil
	if userData == nil {
		return c.Status(http.StatusUnauthorized).JSON(fiber.Map{
			"error": "Invalid token data",
		})
	}

	// ตั้งค่าข้อมูล user ให้กับ context
	c.Locals("user", userData)

	return c.Next()
}
