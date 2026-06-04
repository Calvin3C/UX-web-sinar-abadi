package main

import (
	"fmt"
	"sinar-abadi-backend/config"
	"sinar-abadi-backend/models"
)

func main() {
	config.ConnectDatabase()
	
	// Set BiteshipAreaID for the recent empty ones to fix it so the user can test validation again
	var shippings []models.Shipping
	config.DB.Where("biteship_area_id = ?", "").Find(&shippings)

	for _, s := range shippings {
		if s.ShippingMethodName != "Ambil Di Toko" && s.ShippingMethodName != "Kurir Toko Sinar Abadi" {
			// Just inject a dummy or default area id for testing, or klojen
			s.BiteshipAreaID = "IDNP11IDNC250IDND2600IDZ65116" // Klojen
			config.DB.Save(&s)
			fmt.Printf("Fixed shipping %d (%s)\n", s.ID, s.OrderID)
		}
	}
}
