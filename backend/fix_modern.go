package main

import (
	"fmt"
	"strings"
	"sinar-abadi-backend/config"
	"sinar-abadi-backend/models"
)

func main() {
	config.ConnectDatabase()
	
	var products []models.Product
	config.DB.Find(&products)
	
	count := 0
	for _, p := range products {
		name := strings.ToLower(p.Name)
		if strings.Contains(name, "modern") {
			updates := map[string]interface{}{"brand": "Modern"}
			if err := config.DB.Model(&p).Updates(updates).Error; err == nil {
				fmt.Printf("Updated %s (%s) - Brand: Modern\n", p.ID, p.Name)
				count++
			}
		}
	}
	fmt.Printf("Successfully updated %d products with brand 'Modern'\n", count)
}
