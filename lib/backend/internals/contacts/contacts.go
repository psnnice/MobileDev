package contacts

import (
    "database/sql"
    "flutter_project/pkg/utils"
    "net/http"

    "github.com/gofiber/fiber/v2"
)

type Contact struct {
    ID           int    `json:"id"`
    ImagePath    string `json:"imagePath"`
    ProfileImage string `json:"profileImage"`
    Title        string `json:"title"`
    Email        string `json:"email"`
    PhoneNumber  string `json:"phoneNumber"`
    URL          string `json:"url"`
    UserID       int    `json:"user_id"`    // เพิ่ม user_id
    CreatedAt    string `json:"createdAt"`
}

// Handler สำหรับดึง Contact ทั้งหมด
func GetContactHandler(c *fiber.Ctx) error {
    contactList, err := GetAllContacts() // เรียกใช้ฟังก์ชัน GetAllContacts
    if err != nil {
        return c.Status(fiber.StatusInternalServerError).SendString("Failed to fetch contacts")
    }

    return c.JSON(contactList) // ส่งผลลัพธ์ในรูปแบบ JSON
}

// ดึง Contact ทั้งหมดจากฐานข้อมูล
func GetAllContacts() ([]Contact, error) {
    rows, err := utils.DB.Query("SELECT id, image_path, profile_image, title, email, phone_number, url, user_id, created_at FROM contacts")
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    var contactList []Contact
    for rows.Next() {
        var (
            id           int
            imagePath    sql.NullString
            profileImage sql.NullString
            title        sql.NullString
            email        sql.NullString
            phoneNumber  sql.NullString
            url          sql.NullString
            userID       sql.NullInt32
            createdAt    sql.NullString
        )

        err := rows.Scan(&id, &imagePath, &profileImage, &title, &email, &phoneNumber, &url, &userID, &createdAt)
        if err != nil {
            return nil, err
        }

        contact := Contact{
            ID:           id,
            ImagePath:    nullableStringToDefault(imagePath),
            ProfileImage: nullableStringToDefault(profileImage),
            Title:        nullableStringToDefault(title),
            Email:        nullableStringToDefault(email),
            PhoneNumber:  nullableStringToDefault(phoneNumber),
            URL:          nullableStringToDefault(url),
            UserID:       nullableIntToDefault(userID),
            CreatedAt:    nullableStringToDefault(createdAt),
        }

        contactList = append(contactList, contact)
    }

    // ตรวจสอบ error ระหว่างการอ่านข้อมูล
    if err = rows.Err(); err != nil {
        return nil, err
    }

    return contactList, nil
}

func InsertContact(db *sql.DB, contact Contact) error {
    query := `
        INSERT INTO contacts (image_path, profile_image, title, email, phone_number, url, user_id)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
    `
    _, err := db.Exec(query, contact.ImagePath, contact.ProfileImage, contact.Title, contact.Email, contact.PhoneNumber, contact.URL, contact.UserID)
    return err
}

func InsertContactHandler(c *fiber.Ctx) error {
    var contact Contact
    if err := c.BodyParser(&contact); err != nil {
        return c.Status(http.StatusBadRequest).SendString("Invalid request payload: " + err.Error())
    }

    // Validate contact data if necessary
    if contact.Title == "" || contact.Email == "" {
        return c.Status(http.StatusBadRequest).SendString("Missing required contact fields")
    }

    // Call InsertContact function to insert the contact
    if err := InsertContact(utils.DB, contact); err != nil {
        return c.Status(http.StatusInternalServerError).SendString("Failed to insert contact: " + err.Error())
    }

    return c.Status(http.StatusCreated).SendString("Contact inserted successfully")
}

// Handler สำหรับอัปเดต Contact
func UpdateContactHandler(c *fiber.Ctx) error {
    id, err := c.ParamsInt("id")
    if err != nil {
        return c.Status(http.StatusBadRequest).SendString("Invalid contact ID")
    }

    var contact Contact
    if err := c.BodyParser(&contact); err != nil {
        return c.Status(http.StatusBadRequest).SendString("Invalid request payload: " + err.Error())
    }

    // Validate contact data if necessary
    if contact.Title == "" || contact.Email == "" {
        return c.Status(http.StatusBadRequest).SendString("Missing required contact fields")
    }

    // Call UpdateContact function to update the contact
    if err := UpdateContact(utils.DB, id, contact); err != nil {
        return c.Status(fiber.StatusInternalServerError).SendString("Failed to update contact: " + err.Error())
    }

    return c.Status(http.StatusOK).SendString("Contact updated successfully")
}

// อัปเดต Contact ในฐานข้อมูล
func UpdateContact(db *sql.DB, id int, contact Contact) error {
    query := `
        UPDATE contacts
        SET image_path = $1, profile_image = $2, title = $3, email = $4, phone_number = $5, url = $6, user_id = $7
        WHERE id = $8
    `
    _, err := db.Exec(query, contact.ImagePath, contact.ProfileImage, contact.Title, contact.Email, contact.PhoneNumber, contact.URL, contact.UserID, id)
    return err
}

func DeleteContact(db *sql.DB, id int) error {
    query := "DELETE FROM contacts WHERE id = $1"
    _, err := db.Exec(query, id)
    return err
}

// DeleteContactHandler handles the deletion of a contact
func DeleteContactHandler(c *fiber.Ctx) error {
    id, err := c.ParamsInt("id")
    if err != nil {
        return c.Status(http.StatusBadRequest).SendString("Invalid contact ID")
    }

    // Call DeleteContact function to delete the contact
    if err := DeleteContact(utils.DB, id); err != nil {
        return c.Status(http.StatusInternalServerError).SendString("Failed to delete contact: " + err.Error())
    }

    return c.Status(http.StatusOK).SendString("Contact deleted successfully")
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