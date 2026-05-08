package models

import "time"

// Owner represents the system owner who has full access.
type Owner struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	Username  string    `gorm:"uniqueIndex;size:100;not null" json:"username"`
	Password  string    `gorm:"not null" json:"-"` // never exposed in JSON responses
	Name      string    `gorm:"size:200;not null" json:"name"`
	Role      string    `gorm:"-" json:"role"` // Computed or hardcoded in response for frontend compatibility
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}
