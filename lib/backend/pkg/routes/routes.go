package routes

import (
	"flutter_project/internals/auth"
	"flutter_project/internals/bus"
	"flutter_project/internals/contacts"
	"flutter_project/internals/news"
	"flutter_project/pkg/middleware"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(app *fiber.App) {
	app.Post("/register", auth.RegisterHandler)
	app.Post("/login", auth.LoginHandler)

	app.Post("/DataBus", middleware.CheckToken, bus.InsertDeviceDataHandler)
	app.Get("/DataBus", bus.GetDeviceDataHandler)

	app.Post("/news", middleware.CheckToken, news.InsertNewsHandler)
	app.Get("/news", news.GetNewsHandler)
	app.Put("/news/:id", middleware.CheckToken, news.UpdateNewsHandler)
	app.Delete("/news/:id", middleware.CheckToken, news.DeleteNewsHandler)

	app.Post("/contacts", middleware.CheckToken, contacts.InsertContactHandler)
	app.Get("/contacts", contacts.GetContactHandler)
	app.Put("/contacts/:id", middleware.CheckToken, contacts.UpdateContactHandler)
	app.Delete("/contacts/:id", middleware.CheckToken, contacts.DeleteContactHandler)
}
