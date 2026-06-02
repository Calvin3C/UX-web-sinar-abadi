package main

import (
	"fmt"
	"os"

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
	
	var count int64
	db.Table("stock_logs").Count(&count)
	fmt.Println("Stock logs count:", count)
	
	var productCount int64
	db.Table("products").Count(&productCount)
	fmt.Println("Products count:", productCount)
	
	// Print a few stock_logs
	type StockLog struct {
		ID          uint
		ProductID   string
		ChangeType  string
		QtyChanged  int
	}
	var logs []StockLog
	db.Table("stock_logs").Limit(5).Find(&logs)
	for _, l := range logs {
		fmt.Printf("Log: %+v\n", l)
	}
}
