package main

import (
	"fmt"
	"os"
	"sinar-abadi-backend/models"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func main() {
	godotenv.Load(".env")
	dsn := "host=" + os.Getenv("DB_HOST") + " user=" + os.Getenv("DB_USER") + " password=" + os.Getenv("DB_PASS") + " dbname=" + os.Getenv("DB_NAME") + " port=" + os.Getenv("DB_PORT") + " sslmode=" + os.Getenv("DB_SSLMODE")
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		fmt.Println("Error connecting:", err)
		return
	}
	
	fmt.Println("Has customers table?", db.Migrator().HasTable("customers"))
	fmt.Println("Has users table?", db.Migrator().HasTable("users"))
	
	var customers []models.Customer
	if err := db.Find(&customers).Error; err != nil {
		fmt.Println("Error querying customers:", err)
	} else {
		fmt.Printf("Found %d customers\n", len(customers))
	}
}
