package controllers

import (
	"net/http"
	"sinar-abadi-backend/config"
	"sinar-abadi-backend/models"

	"github.com/gin-gonic/gin"
)

func GetWarehouses(c *gin.Context) {
	var warehouses []models.Warehouse
	if err := config.DB.Find(&warehouses).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Failed to fetch warehouses"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": warehouses})
}

func CreateWarehouse(c *gin.Context) {
	var input struct {
		Name        string `json:"name" binding:"required"`
		Description string `json:"description"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid input"})
		return
	}

	warehouse := models.Warehouse{
		Name:        input.Name,
		Description: input.Description,
		IsActive:    true,
	}

	if err := config.DB.Create(&warehouse).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Failed to create warehouse"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"success": true, "message": "Warehouse created successfully", "data": warehouse})
}
