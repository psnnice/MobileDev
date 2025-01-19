package routes

import (
	"github.com/gofiber/fiber/v2"
	"flutter_project/internals/auth"
	"flutter_project/internals/news/handler"
)

func SetupRoutes(app *fiber.App) {
	app.Post("/register", auth.RegisterHandler)
	app.Post("/login", auth.LoginHandler)

	app.Get("/health", HealthCheckHandler)
	app.Get("/news", news.GetNewsHandler)
}

func HealthCheckHandler(c *fiber.Ctx) error {
	return c.Status(fiber.StatusOK).SendString("Server is running")
}
