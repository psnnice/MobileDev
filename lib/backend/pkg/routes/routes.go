package routes

import (
	"flutter_project/internals/auth"
	"flutter_project/internals/bus"
	"flutter_project/internals/contacts"
	"flutter_project/internals/news"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(app *fiber.App) {
	app.Post("/register", auth.RegisterHandler)
	app.Post("/login", auth.LoginHandler)

	app.Post("/DataBus", bus.InsertDeviceDataHandler)
	app.Get("/DataBus", bus.GetDeviceDataHandler)
	// ใช้ endpoint เดียวกันสำหรับ GET และ POST

	app.Get("/news", news.GetNewsHandler)
	app.Post("/news", news.InsertNewsHandler)

	app.Post("/contacts", contacts.InsertContactHandler)
	app.Get("/contacts", contacts.GetContactHandler)

}
