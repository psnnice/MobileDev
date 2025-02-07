package news

import (
	"database/sql"
	"flutter_project/pkg/utils"
	"log"
	"net/http"
	"time"

	"github.com/gofiber/fiber/v2"
)

type News struct {
	ID        int    `json:"id"`
	ImagePath string `json:"imagePath"`
	Title     string `json:"title"`
	Content   string `json:"content"`
	URL       string `json:"url"`
	CreatedBy int    `json:"created_by"`
	CreatedAt string `json:"createdAt"`
}

// Handler สำหรับดึงข่าวทั้งหมด
func GetNewsHandler(c *fiber.Ctx) error {
	newsList, err := GetAllNews() // ✅ ดึงข้อมูลข่าวทั้งหมด
	if err != nil {
		c.Status(fiber.StatusInternalServerError)
		return c.JSON(fiber.Map{
			"error":   "Failed to fetch news",
			"details": err.Error(),
		}) // ✅ ส่งรายละเอียด error ไปที่ Client
	}

	// ✅ ป้องกัน null โดยตั้งค่าเป็น []
	if newsList == nil {
		newsList = []News{}
	}

	return c.JSON(newsList) // ✅ ส่งข้อมูลกลับในรูปแบบ JSON
}

// ดึงข่าวทั้งหมดจากฐานข้อมูล
func GetAllNews() ([]News, error) {
	rows, err := utils.DB.Query("SELECT id, image_path, title, content, url, created_by, created_at FROM news")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var newsList []News

	// ตรวจสอบว่ามีข่าวหรือไม่ ถ้าไม่มีให้ return []
	if !rows.Next() {
		return []News{}, nil // ✅ ส่ง [] แทน null
	}

	// ถ้ามีข้อมูลให้เริ่มอ่าน
	for {
		var (
			id        int
			imagePath sql.NullString
			title     sql.NullString
			content   sql.NullString
			url       sql.NullString
			createdBy sql.NullInt32
			createdAt sql.NullString
		)

		err := rows.Scan(&id, &imagePath, &title, &content, &url, &createdBy, &createdAt)
		if err != nil {
			return nil, err
		}

		news := News{
			ID:        id,
			ImagePath: nullableStringToDefault(imagePath),
			Title:     nullableStringToDefault(title),
			Content:   nullableStringToDefault(content),
			URL:       nullableStringToDefault(url),
			CreatedBy: nullableIntToDefault(createdBy),
			CreatedAt: nullableStringToDefault(createdAt),
		}

		newsList = append(newsList, news)

		// ถ้าอ่าน row ล่าสุดแล้วให้ออกจาก loop
		if !rows.Next() {
			break
		}
	}

	return newsList, nil
}

// Handler สำหรับเพิ่มข่าวใหม่
func InsertNewsHandler(c *fiber.Ctx) error {
	var news News
	if err := c.BodyParser(&news); err != nil {
		return c.Status(fiber.StatusBadRequest).SendString("Invalid request payload: " + err.Error())
	}

	// ✅ ตรวจสอบว่าผู้ใช้มีอยู่จริง
	if news.CreatedBy != 0 {
		exists, err := checkUserExists(news.CreatedBy)
		if err != nil || !exists {
			return c.Status(fiber.StatusBadRequest).SendString("Invalid created_by: User does not exist")
		}
	}

	news.CreatedAt = time.Now().Format("2006-01-02 15:04:05")

	if err := InsertNews(utils.DB, news); err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Failed to insert news: " + err.Error())
	}

	return c.Status(fiber.StatusCreated).SendString("News inserted successfully")
}

// ✅ ฟังก์ชันตรวจสอบว่าผู้ใช้มีอยู่จริงหรือไม่
func checkUserExists(userID int) (bool, error) {
	var exists bool
	err := utils.DB.QueryRow("SELECT EXISTS (SELECT 1 FROM users WHERE id = $1)", userID).Scan(&exists)
	return exists, err
}

// เพิ่มข่าวใหม่ลงในฐานข้อมูล
func InsertNews(db *sql.DB, news News) error {
	query := `
    INSERT INTO news (image_path, title, content, url, created_by, created_at)
    VALUES ($1, $2, $3, $4, NULLIF($5, 0), $6)
`
	_, err := db.Exec(query, news.ImagePath, news.Title, news.Content, news.URL, news.CreatedBy, news.CreatedAt)
	return err
}

// Handler สำหรับอัปเดตข่าว
func UpdateNewsHandler(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).SendString("Invalid news ID")
	}

	var news News
	if err := c.BodyParser(&news); err != nil {
		log.Println("Error decoding JSON:", err)
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"Error": "Invalid request data"})
	}

	log.Println("Received Update Request:", news) // 🔍 Log ค่าที่ได้รับ

	// ตรวจสอบว่า created_by มีอยู่ใน users หรือไม่
	exists, err := checkUserExists(news.CreatedBy)
	if err != nil {
		log.Println("Error checking user existence:", err)
	}
	if !exists {
		log.Println("Invalid created_by:", news.CreatedBy)
		return c.Status(fiber.StatusBadRequest).SendString("Invalid created_by: User does not exist")
	}

	// อัปเดตข่าว
	if err := UpdateNews(id, news); err != nil {
		log.Println("Error updating news:", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"Error": "Unable to update news"})
	}

	return c.JSON(fiber.Map{"message": "News updated successfully"})
}

// ✅ ฟังก์ชันตรวจสอบว่าผู้ใช้มีอยู่จริงหรือไม่

// ฟังก์ชันอัปเดตข้อมูลในฐานข้อมูล
func UpdateNews(id int, news News) error {
	if utils.DB == nil {
		log.Println("การเชื่อมต่อฐานข้อมูลล้มเหลว")
		return fiber.NewError(fiber.StatusInternalServerError, "ไม่สามารถเชื่อมต่อฐานข้อมูล")
	}

	_, err := utils.DB.Exec(`
    UPDATE news
    SET image_path = $1, title = $2, content = $3, url = $4, created_by = NULLIF($5, 0), created_at = NOW()
    WHERE id = $6
`, news.ImagePath, news.Title, news.Content, news.URL, news.CreatedBy, id)
	if err != nil {
		log.Println("Errorในการอัปเดตข้อมูล:", err)
		return err
	}

	return nil
}

// ลบข่าวจากฐานข้อมูล
func DeleteNews(db *sql.DB, id int) error {
	query := "DELETE FROM news WHERE id = $1"
	_, err := db.Exec(query, id)
	return err
}

// Handler สำหรับลบข่าว
func DeleteNewsHandler(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(http.StatusBadRequest).SendString("Invalid news ID")
	}

	// Call DeleteNews function to delete the news
	if err := DeleteNews(utils.DB, id); err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Failed to delete news: " + err.Error())
	}

	return c.Status(http.StatusOK).SendString("News deleted successfully")
}

// Helper ฟังก์ชันสำหรับจัดการ NullString
func nullableStringToDefault(ns sql.NullString) string {
	if ns.Valid {
		return ns.String
	}
	return ""
}

// Helper ฟังก์ชันสำหรับจัดการ NullInt32
func nullableIntToDefault(ni sql.NullInt32) int {
	if ni.Valid {
		return int(ni.Int32)
	}
	return 0
}
