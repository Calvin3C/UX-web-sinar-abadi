package models

import "time"

// CustomerAddress represents an address belonging to a customer
type CustomerAddress struct {
	ID             uint      `gorm:"primaryKey" json:"id"`
	CustomerID     uint      `gorm:"not null" json:"customerId"`
	Title          string    `gorm:"size:100;not null" json:"title"` // e.g. "Rumah", "Kantor"
	RecipientName  string    `gorm:"size:200;not null" json:"recipientName"`
	PhoneNumber    string    `gorm:"size:50;not null" json:"phoneNumber"`
	FullAddress    string    `gorm:"type:text;not null" json:"fullAddress"`
	PostalCode     string    `gorm:"size:20" json:"postalCode"`
	BiteshipAreaID string    `gorm:"size:100;not null" json:"biteshipAreaId"` // Important for Biteship API
	IsPrimary      bool      `gorm:"default:false" json:"isPrimary"`
	CreatedAt      time.Time `json:"createdAt"`
	UpdatedAt      time.Time `json:"updatedAt"`
}
