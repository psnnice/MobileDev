package models

type News struct {
    ID        int    `json:"id"`
    ImagePath string `json:"imagePath"`
    Title     string `json:"title"`
    Content   string `json:"content"`
    URL       string `json:"url"`
    CreatedAt string `json:"createdAt"`
}
