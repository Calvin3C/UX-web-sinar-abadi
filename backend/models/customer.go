package models

import "time"

// Customer represents a regular user who makes purchases.
type Customer struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	Username  string    `gorm:"uniqueIndex;size:100;not null" json:"username"`
	Password  string    `gorm:"not null" json:"-"` // never exposed in JSON responses
	Name      string    `gorm:"size:200;not null" json:"name"`
	IsBlocked bool      `gorm:"default:false" json:"isBlocked"`
	Role      string    `gorm:"-" json:"role"` // Computed or hardcoded in response for frontend compatibility
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}
