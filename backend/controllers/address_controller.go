package controllers

import (
	"net/http"

	"sinar-abadi-backend/config"
	"sinar-abadi-backend/models"

	"github.com/gin-gonic/gin"
)

// GetCustomerAddresses returns all addresses for the logged-in customer
func GetCustomerAddresses(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var addresses []models.CustomerAddress
	if err := config.DB.Where("customer_id = ?", userID).Order("is_primary desc, id desc").Find(&addresses).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch addresses"})
		return
	}

	c.JSON(http.StatusOK, addresses)
}

// CreateCustomerAddress adds a new address for the logged-in customer
func CreateCustomerAddress(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var req struct {
		Title          string `json:"title" binding:"required"`
		RecipientName  string `json:"recipientName" binding:"required"`
		PhoneNumber    string `json:"phoneNumber" binding:"required"`
		FullAddress    string `json:"fullAddress" binding:"required"`
		PostalCode     string `json:"postalCode"`
		BiteshipAreaID string `json:"biteshipAreaId" binding:"required"`
		IsPrimary      bool   `json:"isPrimary"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// If marked as primary, reset others
	if req.IsPrimary {
		config.DB.Model(&models.CustomerAddress{}).Where("customer_id = ?", userID).Update("is_primary", false)
	}

	address := models.CustomerAddress{
		CustomerID:     userID.(uint),
		Title:          req.Title,
		RecipientName:  req.RecipientName,
		PhoneNumber:    req.PhoneNumber,
		FullAddress:    req.FullAddress,
		PostalCode:     req.PostalCode,
		BiteshipAreaID: req.BiteshipAreaID,
		IsPrimary:      req.IsPrimary,
	}

	if err := config.DB.Create(&address).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create address"})
		return
	}

	// If it's the first address, make it primary automatically
	var count int64
	config.DB.Model(&models.CustomerAddress{}).Where("customer_id = ?", userID).Count(&count)
	if count == 1 && !address.IsPrimary {
		address.IsPrimary = true
		config.DB.Save(&address)
	}

	c.JSON(http.StatusCreated, address)
}

// UpdateCustomerAddress updates an existing address
func UpdateCustomerAddress(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	addressID := c.Param("id")
	var address models.CustomerAddress
	if err := config.DB.Where("id = ? AND customer_id = ?", addressID, userID).First(&address).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Address not found"})
		return
	}

	var req struct {
		Title          string `json:"title"`
		RecipientName  string `json:"recipientName"`
		PhoneNumber    string `json:"phoneNumber"`
		FullAddress    string `json:"fullAddress"`
		PostalCode     string `json:"postalCode"`
		BiteshipAreaID string `json:"biteshipAreaId"`
		IsPrimary      bool   `json:"isPrimary"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if req.IsPrimary && !address.IsPrimary {
		config.DB.Model(&models.CustomerAddress{}).Where("customer_id = ?", userID).Update("is_primary", false)
	}

	// Update fields
	if req.Title != "" { address.Title = req.Title }
	if req.RecipientName != "" { address.RecipientName = req.RecipientName }
	if req.PhoneNumber != "" { address.PhoneNumber = req.PhoneNumber }
	if req.FullAddress != "" { address.FullAddress = req.FullAddress }
	if req.PostalCode != "" { address.PostalCode = req.PostalCode }
	if req.BiteshipAreaID != "" { address.BiteshipAreaID = req.BiteshipAreaID }
	if req.IsPrimary { address.IsPrimary = req.IsPrimary }

	if err := config.DB.Save(&address).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update address"})
		return
	}

	c.JSON(http.StatusOK, address)
}

// DeleteCustomerAddress deletes an address
func DeleteCustomerAddress(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	addressID := c.Param("id")
	var address models.CustomerAddress
	if err := config.DB.Where("id = ? AND customer_id = ?", addressID, userID).First(&address).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Address not found"})
		return
	}

	if err := config.DB.Delete(&address).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete address"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Address deleted successfully"})
}
