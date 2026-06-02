package models

import "time"

// Product represents a building material item in the catalog.
// Stock is NOT stored here — it is computed from the stock_logs table.
type Product struct {
	ID        string    `gorm:"primaryKey;size:20" json:"id"`   // e.g. "P-001"
	Category  string    `gorm:"size:100;not null" json:"category"`
	Name      string    `gorm:"size:300;not null" json:"name"`
	Price     int64     `gorm:"not null" json:"price"`          // in Rupiah (integer, no floating point)
	Sold      int       `gorm:"not null;default:0" json:"sold"` // popularity counter
	IsLarge   bool      `gorm:"default:false" json:"isLarge"`   // true = heavy/bulky → shipping restriction
	ImageURL  string    `gorm:"size:500" json:"img"`            // JSON key "img" matches frontend
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}

// ProductResponse is the API response struct that includes the computed stock.
// Stock is calculated dynamically from SUM(qty_changed) in stock_logs.
type ProductResponse struct {
	ID        string    `json:"id"`
	Category  string    `json:"category"`
	Name      string    `json:"name"`
	Price     int64     `json:"price"`
	Stock     int       `json:"stock"` // computed from stock_logs
	Sold      int       `json:"sold"`
	IsLarge   bool      `json:"isLarge"`
	ImageURL  string    `json:"img"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}
