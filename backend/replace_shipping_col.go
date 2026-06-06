package main

import (
	"log"

	"sinar-abadi-backend/config"
	"sinar-abadi-backend/models"
)

func main() {
	config.ConnectDatabase()
	db := config.DB

	log.Println("Dropping shipping_method_id column from shippings...")

	if db.Migrator().HasColumn(&models.Shipping{}, "shipping_method_id") {
		if err := db.Migrator().DropColumn(&models.Shipping{}, "shipping_method_id"); err != nil {
			log.Fatalf("Failed to drop column from shippings: %v", err)
		}
	}

	// AutoMigrate to add the new admin_id column and its foreign key
	err := db.AutoMigrate(&models.Shipping{})
	if err != nil {
		log.Fatalf("Failed to AutoMigrate models.Shipping: %v", err)
	}

	log.Println("Success replacing shipping_method_id with admin_id.")
}
