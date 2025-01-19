package utils

import (
	"os"
	"time"

	"github.com/golang-jwt/jwt/v4"
	"github.com/joho/godotenv"
)

var jwtSecret []byte

// โหลดค่า JWT Secret จาก .env
func init() {
	
	// โหลดไฟล์ .env
	err := godotenv.Load()
	if err != nil {
		panic("Error loading .env file")
	}

	// ดึงค่า JWT_SECRET
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		panic("JWT_SECRET is not set in .env file")
	}

	jwtSecret = []byte(secret)
}

// GenerateToken: สร้าง JWT Token
func GenerateToken(username string) (string, error) {
	claims := jwt.MapClaims{
		"username": username,
		"exp":      time.Now().Add(time.Hour * 24).Unix(), // Token หมดอายุใน 24 ชั่วโมง
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtSecret)
}

// ValidateToken: ตรวจสอบความถูกต้องของ Token
func ValidateToken(tokenStr string) (jwt.MapClaims, error) {
	token, err := jwt.Parse(tokenStr, func(token *jwt.Token) (interface{}, error) {
		return jwtSecret, nil
	})

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		return claims, nil
	} else {
		return nil, err
	}
}
