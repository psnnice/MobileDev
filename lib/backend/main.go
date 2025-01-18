package main

import (
	"log"

	"github.com/gofiber/fiber/v2"
	"github.com/joho/godotenv"

	"flutter_project/utils"
	"flutter_project/middleware"
	"flutter_project/routes"
)

func main() {

	// โหลดไฟล์ .env
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	// เชื่อมต่อฐานข้อมูล
	utils.InitDB()
	defer utils.CloseDB()

	// สร้าง Fiber แอป
	app := fiber.New()

	// Middleware
	app.Use(middleware.RateLimiter())
	app.Use(middleware.Logger())
	
	// กำหนด Routes
	routes.SetupRoutes(app)

	// เริ่มต้นเซิร์ฟเวอร์
	log.Fatal(app.Listen(":8080"))
}
