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
		newBrand := ""
		
		if strings.Contains(name, "eterna") {
			newBrand = "Eterna"
		} else if strings.Contains(name, "imundex") {
			newBrand = "Imundex"
		}
		
		if newBrand != "" && p.Brand != newBrand {
			updates := map[string]interface{}{"brand": newBrand}
			if err := config.DB.Model(&p).Updates(updates).Error; err == nil {
				fmt.Printf("Updated %s (%s) - Brand: %s\n", p.ID, p.Name, newBrand)
				count++
			}
		}
	}
	fmt.Printf("Successfully updated %d brush products.\n", count)
}
