package routes

import (
	"github.com/gofiber/fiber/v2"
	"flutter_project/internals/auth"
	"flutter_project/internals/news"
	"flutter_project/internals/contacts"
)

func SetupRoutes(app *fiber.App) {
	app.Post("/register", auth.RegisterHandler)
	app.Post("/login", auth.LoginHandler)

	app.Get("/health", HealthCheckHandler)
	app.Get("/news", news.GetNewsHandler)
	app.Get("/contacts", contacts.GetContactHandler)
}

func HealthCheckHandler(c *fiber.Ctx) error {
	return c.Status(fiber.StatusOK).SendString("Server is running")
}
