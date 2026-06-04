package main

import (
	"fmt"
	"log"
	"sinar-abadi-backend/config"
	"sinar-abadi-backend/models"

	"github.com/joho/godotenv"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found")
	}
	config.ConnectDatabase()

	var shipping models.Shipping
	if err := config.DB.Where("order_id = ?", "ORD-260603-721").First(&shipping).Error; err != nil {
		fmt.Println("Error:", err)
		return
	}

	// Fix the order
	result := config.DB.Model(&shipping).Updates(map[string]interface{}{
		"biteship_order_id": "TEST-ORDER-ID-12345",
		"waybill_id":        "TEST-WAYBILL-ID",
	})
	fmt.Println("Rows affected:", result.RowsAffected)
	fmt.Println("Error:", result.Error)
}
