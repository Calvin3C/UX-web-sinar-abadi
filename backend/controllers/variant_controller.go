package controllers

import (
	"net/http"
	"sinar-abadi-backend/config"
	"sinar-abadi-backend/models"

	"github.com/gin-gonic/gin"
)

type VariantInput struct {
	Name  string `json:"name" binding:"required"`
	Price int64  `json:"price"`
}

// CreateVariant handles creating a new variant for a product.
// POST /api/products/:id/variants
func CreateVariant(c *gin.Context) {
	productID := c.Param("id")
	var input VariantInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input tidak valid"})
		return
	}

	// Verify product exists
	var product models.Product
	if err := config.DB.Where("id = ?", productID).First(&product).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Produk tidak ditemukan"})
		return
	}

	variant := models.ProductVariant{
		ProductID: productID,
		Name:      input.Name,
		Price:     input.Price,
	}

	if err := config.DB.Create(&variant).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan varian"})
		return
	}

	c.JSON(http.StatusCreated, variant)
}

// DeleteVariant handles removing a variant.
// DELETE /api/products/:id/variants/:variantId
func DeleteVariant(c *gin.Context) {
	productID := c.Param("id")
	variantID := c.Param("variantId")

	result := config.DB.Where("id = ? AND product_id = ?", variantID, productID).Delete(&models.ProductVariant{})
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus varian"})
		return
	}
	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Varian tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Varian berhasil dihapus"})
}
