package main

import (
	"log"
	"sinar-abadi-backend/config"
	"sinar-abadi-backend/models"
)

func main() {
	config.ConnectDatabase()
	if err := config.DB.AutoMigrate(&models.ProductVariant{}); err != nil {
		log.Fatal(err)
	}

	variants := []models.ProductVariant{
		{ProductID: "P-075", Name: "Biru Muda"},
		{ProductID: "P-075", Name: "Merah Muda"},
		{ProductID: "P-075", Name: "Putih"},
		{ProductID: "P-075", Name: "Merah Maroon", Price: 295000},

		{ProductID: "P-076", Name: "Biru Muda"},
		{ProductID: "P-076", Name: "Merah Muda"},
		{ProductID: "P-076", Name: "Putih"},
		{ProductID: "P-076", Name: "Merah Maroon", Price: 295000},

		{ProductID: "P-077", Name: "Biru Muda"},
		{ProductID: "P-077", Name: "Merah Muda"},
		{ProductID: "P-077", Name: "Putih"},
		{ProductID: "P-077", Name: "Merah Maroon", Price: 225000},

		{ProductID: "P-078", Name: "Biru Muda"},
		{ProductID: "P-078", Name: "Merah Muda"},
		{ProductID: "P-078", Name: "Putih"},

		{ProductID: "P-079", Name: "Biru Muda"},
		{ProductID: "P-079", Name: "Merah Muda"},
		{ProductID: "P-079", Name: "Putih"},

		{ProductID: "P-080", Name: "Biru Muda"},
		{ProductID: "P-080", Name: "Merah Muda"},
		{ProductID: "P-080", Name: "Putih"},
	}

	// Delete existing kloset variants first to avoid duplicates
	config.DB.Where("product_id IN (?)", []string{"P-075", "P-076", "P-077", "P-078", "P-079", "P-080"}).Delete(&models.ProductVariant{})

	for _, v := range variants {
		config.DB.Create(&v)
	}
	log.Println("Kloset variants seeded successfully!")
}
