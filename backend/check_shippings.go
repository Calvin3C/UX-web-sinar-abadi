package main

import (
	"fmt"
	"sinar-abadi-backend/config"
	"sinar-abadi-backend/models"
)

func main() {
	config.ConnectDatabase()
	var shipping models.Shipping
	config.DB.Order("id desc").First(&shipping)
	fmt.Printf("Latest Shipping: %+v\n", shipping)
}
