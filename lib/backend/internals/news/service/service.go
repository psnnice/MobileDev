package service

import (
    "flutter_project/internals/news/models"
    "flutter_project/internals/news/repository"
)

func GetAllNews() ([]models.News, error) {
    return repository.FetchNews()
}