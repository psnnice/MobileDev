package description_map

import (
	"database/sql"
	"flutter_project/pkg/utils"
	"log"

	"github.com/gofiber/fiber/v2"
)

// โครงสร้างข้อมูลของตาราง description_map
type DescriptionMap struct {
	ID          int    `json:"id"`
	RouteName   string `json:"route_name"`
	ImagePath   string `json:"image_path"`
	Description string `json:"description"`
	StationList string `json:"station_list"`
	Note        string `json:"note,omitempty"` // omitempty ทำให้ไม่ส่งค่า null ไป
	CreatedBy   int    `json:"created_by"`
	CreatedAt   string `json:"created_at"`
}

// Handler สำหรับดึงข้อมูลจาก description_map
func GetDescriptionMapHandler(c *fiber.Ctx) error {
	descriptionMapList, err := GetAllDescriptionMaps()
	if err != nil {
		log.Println("เกิดข้อผิดพลาดในการดึงข้อมูล:", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"ข้อผิดพลาด": "ไม่สามารถดึงข้อมูลเส้นทางได้",
		})
	}

	// ถ้าไม่มีข้อมูล ให้คืนค่าเป็นอาร์เรย์ว่าง []
	if len(descriptionMapList) == 0 {
		return c.JSON([]DescriptionMap{})
	}

	return c.JSON(descriptionMapList)
}

// ฟังก์ชันดึงข้อมูลทั้งหมดจาก description_map
func GetAllDescriptionMaps() ([]DescriptionMap, error) {
	// ตรวจสอบว่า Database Connection ใช้งานได้
	if utils.DB == nil {
		log.Println("การเชื่อมต่อฐานข้อมูลล้มเหลว")
		return nil, fiber.NewError(fiber.StatusInternalServerError, "ไม่สามารถเชื่อมต่อฐานข้อมูล")
	}

	// ดึงข้อมูลจากฐานข้อมูล
	rows, err := utils.DB.Query(`
		SELECT id, route_name, image_path, description, station_list, note, created_by, created_at
		FROM description_map
	`)
	if err != nil {
		log.Println("ข้อผิดพลาดในการ Query:", err)
		return nil, err
	}
	defer rows.Close()

	// อ่านข้อมูลจาก rows
	var descriptionMapList []DescriptionMap
	for rows.Next() {
		var descriptionMap DescriptionMap
		var createdBy sql.NullInt32
		var note sql.NullString

		err := rows.Scan(
			&descriptionMap.ID,
			&descriptionMap.RouteName,
			&descriptionMap.ImagePath,
			&descriptionMap.Description,
			&descriptionMap.StationList,
			&note,      // รองรับค่าว่าง
			&createdBy, // รองรับค่าว่าง
			&descriptionMap.CreatedAt,
		)
		if err != nil {
			log.Println("ข้อผิดพลาดในการอ่านข้อมูล:", err)
			return nil, err
		}

		// แปลงค่า NULL เป็นค่าเริ่มต้น
		descriptionMap.Note = nullableStringToDefault(note)
		descriptionMap.CreatedBy = nullableIntToDefault(createdBy)

		descriptionMapList = append(descriptionMapList, descriptionMap)
	}

	// ตรวจสอบ error ระหว่างการอ่านข้อมูล
	if err = rows.Err(); err != nil {
		log.Println("เกิดข้อผิดพลาดขณะอ่านข้อมูล:", err)
		return nil, err
	}

	return descriptionMapList, nil
}

// Helper ฟังก์ชันสำหรับจัดการ NullString
func nullableStringToDefault(ns sql.NullString) string {
	if ns.Valid {
		return ns.String
	}
	return "" // คืนค่าสตริงว่างแทน NULL
}

// Helper ฟังก์ชันสำหรับจัดการ NullInt32
func nullableIntToDefault(ni sql.NullInt32) int {
	if ni.Valid {
		return int(ni.Int32)
	}
	return 0 // คืนค่า 0 แทน NULL
}
