package controllers

import (
	"net/http"

	"sinar-abadi-backend/services"

	"github.com/gin-gonic/gin"
)

// SearchBiteshipAreas handles the request to search areas via Biteship Maps API
func SearchBiteshipAreas(c *gin.Context) {
	input := c.Query("input")
	if input == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "input query parameter is required (e.g., postal code or subdistrict)"})
		return
	}

	result, err := services.SearchAreas(input)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch areas from Biteship: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, result)
}

// CalculateRates handles the POST request to fetch shipping rates from Biteship
func CalculateRates(c *gin.Context) {
	var req struct {
		DestinationAreaID string                   `json:"destinationAreaId" binding:"required"`
		Couriers          string                   `json:"couriers" binding:"required"`
		Items             []map[string]interface{} `json:"items" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Hardcode Sinar Abadi's Origin Area ID (Dampit, Malang)
	// You should use the actual Biteship Area ID for Sinar Abadi's location.
	originAreaID := "IDNP11IDNC250IDND2604IDZ65181" // ID for Dampit, Malang. 65181

	result, err := services.GetRates(originAreaID, req.DestinationAreaID, req.Couriers, req.Items)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to calculate rates: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, result)
}

// BiteshipWebhook handles status updates from Biteship
func BiteshipWebhook(c *gin.Context) {
	// Biteship sends a payload with order status
	var payload struct {
		Event       string `json:"event"`
		OrderID     string `json:"order_id"`
		Status      string `json:"status"`
		ReferenceID string `json:"reference_id"` // This is our order_id
	}

	if err := c.ShouldBindJSON(&payload); err != nil {
		// Just log and return 200 so Biteship doesn't retry infinitely on bad payload
		c.JSON(http.StatusOK, gin.H{"message": "Webhook received with bad payload"})
		return
	}

	// For the activation test, they might send a dummy webhook
	// A simple 200 OK is enough for Biteship to verify the webhook is alive
	c.JSON(http.StatusOK, gin.H{"message": "Webhook received successfully"})
}
