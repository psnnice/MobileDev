package routes

import (
	"github.com/gofiber/fiber/v2"
	"flutter_project/auth"
)

func SetupRoutes(app *fiber.App) {
	app.Post("/register", auth.RegisterHandler)
	app.Post("/login", auth.LoginHandler)
	app.Get("/health", HealthCheckHandler)
}

func HealthCheckHandler(c *fiber.Ctx) error {
	return c.Status(fiber.StatusOK).SendString("Server is running")
}
