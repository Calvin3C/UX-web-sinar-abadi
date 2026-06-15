package main

import (
	"encoding/json"
	"log"
	"sinar-abadi-backend/config"
	"sinar-abadi-backend/models"

	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load()
	config.ConnectDatabase()
	var products []models.Product
	config.DB.Preload("WarehouseStocks").Where("name ILIKE ?", "%Semen Gresik%").Find(&products)
	b, _ := json.MarshalIndent(products, "", "  ")
	log.Println(string(b))
}
