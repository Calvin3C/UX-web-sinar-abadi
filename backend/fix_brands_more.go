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
		
		if strings.Contains(name, "philips") {
			newBrand = "Philips"
		} else if strings.Contains(name, "muller") {
			newBrand = "Muller"
		} else if strings.Contains(name, "wanli") {
			newBrand = "WanLi"
		} else if strings.Contains(name, "zeona") {
			newBrand = "Zeona"
		} else if strings.Contains(name, "nishio") {
			newBrand = "Nishio"
		} else if strings.Contains(name, " ina") || strings.HasSuffix(name, "ina") {
			newBrand = "INA"
		} else if strings.Contains(name, "duty") {
			newBrand = "Duty"
		} else if strings.Contains(name, "volk") {
			newBrand = "Volk"
		} else if strings.Contains(name, "triliun") {
			newBrand = "Triliun"
		}
		
		if newBrand != "" && p.Brand != newBrand {
			updates := map[string]interface{}{"brand": newBrand}
			if err := config.DB.Model(&p).Updates(updates).Error; err == nil {
				fmt.Printf("Updated %s (%s) - Brand: %s\n", p.ID, p.Name, newBrand)
				count++
			}
		}
	}
	fmt.Printf("Successfully updated %d additional products.\n", count)
}
