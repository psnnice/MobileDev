package news

import (
    "github.com/gofiber/fiber/v2"
    "flutter_project/pkg/utils"
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
        var news News
        err := rows.Scan(&news.ID, &news.ImagePath, &news.Title, &news.Content, &news.URL, &news.CreatedAt)
        if err != nil {
            return nil, err
        }
        newsList = append(newsList, news)
    }

    // ตรวจสอบ error ระหว่างการอ่านข้อมูล
    if err = rows.Err(); err != nil {
        return nil, err
    }

    return newsList, nil
}
