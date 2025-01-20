package news

import (
    "database/sql"
    "flutter_project/pkg/utils"
    "github.com/gofiber/fiber/v2"
    "net/http"
    "time"
)

type News struct {
    ID        int    `json:"id"`
    ImagePath string `json:"imagePath"`
    Title     string `json:"title"`
    Content   string `json:"content"`
    URL       string `json:"url"`
    CreatedAt string `json:"createdAt"`
}

// Handler สำหรับดึงข่าวทั้งหมด
func GetNewsHandler(c *fiber.Ctx) error {
    newsList, err := GetAllNews() // เรียกใช้ฟังก์ชัน GetAllNews
    if err != nil {
        return c.Status(fiber.StatusInternalServerError).SendString("Failed to fetch news")
    }

    return c.JSON(newsList) // ส่งผลลัพธ์ในรูปแบบ JSON
}

// ดึงข่าวทั้งหมดจากฐานข้อมูล
func GetAllNews() ([]News, error) {
    rows, err := utils.DB.Query("SELECT id, image_path, title, content, url, created_at FROM news")
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    var newsList []News
    for rows.Next() {
        var (
            id        int
            imagePath sql.NullString
            title     sql.NullString
            content   sql.NullString
            url       sql.NullString
            createdAt sql.NullString
        )

        err := rows.Scan(&id, &imagePath, &title, &content, &url, &createdAt)
        if err != nil {
            return nil, err
        }

        news := News{
            ID:        id,
            ImagePath: nullableStringToDefault(imagePath),
            Title:     nullableStringToDefault(title),
            Content:   nullableStringToDefault(content),
            URL:       nullableStringToDefault(url),
            CreatedAt: nullableStringToDefault(createdAt),
        }

        newsList = append(newsList, news)
    }

    // ตรวจสอบ error ระหว่างการอ่านข้อมูล
    if err = rows.Err(); err != nil {
        return nil, err
    }

    return newsList, nil
}

// Handler สำหรับเพิ่มข่าวใหม่
func InsertNewsHandler(c *fiber.Ctx) error {
    var news News
    if err := c.BodyParser(&news); err != nil {
        return c.Status(fiber.StatusBadRequest).SendString("Invalid request payload: " + err.Error())
    }

    // Validate news data if necessary
    if news.Title == "" || news.Content == "" {
        return c.Status(fiber.StatusBadRequest).SendString("Missing required news fields")
    }

    news.CreatedAt = time.Now().Format("2006-01-02 15:04:05")

    // Call InsertNews function to insert the news
    if err := InsertNews(utils.DB, news); err != nil {
        return c.Status(fiber.StatusInternalServerError).SendString("Failed to insert news: " + err.Error())
    }

    return c.Status(fiber.StatusCreated).SendString("News inserted successfully")
}

// เพิ่มข่าวใหม่ลงในฐานข้อมูล
func InsertNews(db *sql.DB, news News) error {
    query := `
        INSERT INTO news (image_path, title, content, url, created_at)
        VALUES ($1, $2, $3, $4, $5)
    `
    _, err := db.Exec(query, news.ImagePath, news.Title, news.Content, news.URL, news.CreatedAt)
    return err
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