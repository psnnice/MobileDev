package main

import (
	"database/sql"
	"log"
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

var db *sql.DB

// เชื่อม DB
func initDB() {
	// .env
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file:", err)
	}

	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_NAME")
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")
	dbSSLMode := os.Getenv("DB_SSLMODE")

	connStr := "user=" + dbUser +
		" password=" + dbPassword +
		" dbname=" + dbName +
		" host=" + dbHost +
		" port=" + dbPort +
		" sslmode=" + dbSSLMode

	db, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("เชื่อม DATABASE ไม่ได้โว้ยย:", err)
	}

	err = db.Ping()
	if err != nil {
		log.Fatal("DATABASE หายยย:", err)
	}
	log.Println("เชื่อม DATABASE ได้ละ")
}

type User struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

// func register
func registerHandler(c *fiber.Ctx) error {
	var user User
	if err := c.BodyParser(&user); err != nil {
		return c.Status(fiber.StatusBadRequest).SendString("Invalid request")
	}

	if user.Username == "" || user.Password == "" {
		return c.Status(fiber.StatusBadRequest).SendString("Please provide both username and password")
	}

	_, err := db.Exec("INSERT INTO users (username, password) VALUES ($1, $2)", user.Username, user.Password)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Failed to register user")
	}

	return c.Status(fiber.StatusCreated).SendString("User registered successfully")
}

// func login
func loginHandler(c *fiber.Ctx) error {
	var user User
	if err := c.BodyParser(&user); err != nil {
		return c.Status(fiber.StatusBadRequest).SendString("Wrong request")
	}

	if user.Username == "" || user.Password == "" {
		return c.Status(fiber.StatusBadRequest).SendString("Please provide both username and password")
	}

	var storedPassword string
	err := db.QueryRow("SELECT password FROM users WHERE username=$1", user.Username).Scan(&storedPassword)
	if err == sql.ErrNoRows || storedPassword != user.Password {
		return c.Status(fiber.StatusUnauthorized).SendString("Invalid username or password")
	} else if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Failed to authenticate user")
	}

	return c.Status(fiber.StatusOK).SendString("User authenticated successfully")
}

// func check
func healthCheckHandler(c *fiber.Ctx) error {
	if err := db.Ping(); err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Sever ไม่พร้อมใช้งาน")
	}
	return c.Status(fiber.StatusOK).SendString("Sever พร้อมทำงาน")
}

func main() {
	initDB()
	defer db.Close()

	app := fiber.New()

	app.Post("/register", registerHandler)
	app.Post("/login", loginHandler)
	app.Get("/check", healthCheckHandler)

	log.Fatal(app.Listen(":8080"))
}
