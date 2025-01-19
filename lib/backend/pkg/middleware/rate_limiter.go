package middleware

import (
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/limiter"
)

func RateLimiter() fiber.Handler {
	return limiter.New(limiter.Config{
		Expiration: 1 * time.Minute,
		Max:        60, // จำกัด 60 requests ต่อนาที
	})
}
