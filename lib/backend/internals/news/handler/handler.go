package news

import (
    "github.com/gofiber/fiber/v2"
    "flutter_project/internals/news/service"
)

func GetNewsHandler(c *fiber.Ctx) error {
    newsList, err := service.GetAllNews()
    if err != nil {
        return c.Status(fiber.StatusInternalServerError).SendString("Failed to fetch news")
    }

    return c.JSON(newsList)
}
