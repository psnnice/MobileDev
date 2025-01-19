package repository

import (
    "flutter_project/pkg/utils"
    "flutter_project/internals/news/models"
)

func FetchNews() ([]models.News, error) {

    rows, err := utils.DB.Query("SELECT id, image_path, title, content, url, created_at FROM news")
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    var newsList []models.News
    for rows.Next() {
        var news models.News
        err := rows.Scan(&news.ID, &news.ImagePath, &news.Title, &news.Content, &news.URL, &news.CreatedAt)
        if err != nil {
            return nil, err
        }
        newsList = append(newsList, news)
    }

    if err = rows.Err(); err != nil {
        return nil, err
    }

    return newsList, nil
}
