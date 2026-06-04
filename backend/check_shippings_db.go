package main

import (
	"fmt"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

type Shipping struct {
	ID                 uint
	OrderID            string
	ShippingMethodName string
	BiteshipAreaID     string
	TrackingNumber     string
	BiteshipOrderID    string
	WaybillID          string
}

func main() {
	db, err := gorm.Open(sqlite.Open("sinarabadi.db"), &gorm.Config{})
	if err != nil {
		panic(err)
	}

	var shipping Shipping
	db.Order("id desc").First(&shipping)
	fmt.Printf("Shipping: %+v\n", shipping)
}
