package middleware

import (
	"github.com/gofiber/fiber/v2"
)

func ContentType() fiber.Handler {
	return func(c *fiber.Ctx) error {
		c.Set("Content-Type", "application/json; charset=utf-8")
		return c.Next()
	}
}
