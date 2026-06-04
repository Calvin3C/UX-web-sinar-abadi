package main

import (
	"fmt"
	"sinar-abadi-backend/config"
	"sinar-abadi-backend/models"
)

func main() {
	config.ConnectDatabase()
	
	for _, id := range []string{"P-033", "P-034"} {
		var product models.Product
		if err := config.DB.Where("id = ?", id).First(&product).Error; err == nil {
			fmt.Printf("Updating %s (%s). Current brand: %s\n", product.ID, product.Name, product.Brand)
			updates := map[string]interface{}{"brand": "Maspion"}
			config.DB.Model(&product).Updates(updates)
		}
	}
}
