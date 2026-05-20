package controllers

import (
	"net/http"
	"strings"

	"sinar-abadi-backend/config"
	"sinar-abadi-backend/models"

	"github.com/gin-gonic/gin"
)

// CreateProductInput represents the request body for creating a new product.
type CreateProductInput struct {
	ID       string `json:"id" binding:"required"`
	Category string `json:"category" binding:"required"`
	Name     string `json:"name" binding:"required"`
	Price    int64  `json:"price" binding:"required"`
	Stock    int    `json:"stock"`
	IsLarge  bool   `json:"isLarge"`
	ImageURL string `json:"img"`
}

// StockUpdateInput represents the request body for stock adjustment.
type StockUpdateInput struct {
	Amount int `json:"amount" binding:"required"` // positive = add, negative = subtract
}

// GetProducts returns a list of products with optional filtering and sorting.
// GET /api/products?search=xxx&category=xxx&sort=termurah|termahal|az|rekomendasi
func GetProducts(c *gin.Context) {
	var products []models.Product

	query := config.DB.Model(&models.Product{})

	// Search filter (by name)
	if search := c.Query("search"); search != "" {
		search = "%" + strings.ToLower(search) + "%"
		query = query.Where("LOWER(name) LIKE ?", search)
	}

	// Category filter
	if category := c.Query("category"); category != "" && category != "all" {
		query = query.Where("category = ?", category)
	}

	// Sorting
	switch c.Query("sort") {
	case "termurah":
		query = query.Order("price ASC")
	case "termahal":
		query = query.Order("price DESC")
	case "az":
		query = query.Order("name ASC")
	default: // "rekomendasi" — sort by most sold
		query = query.Order("sold DESC")
	}

	if result := query.Find(&products); result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data produk"})
		return
	}

	c.JSON(http.StatusOK, products)
}

// CreateProduct creates a new product. Admin/Owner only.
// POST /api/products
func CreateProduct(c *gin.Context) {
	var input CreateProductInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data produk tidak lengkap"})
		return
	}

	// Check for duplicate ID
	var existing models.Product
	if result := config.DB.Where("id = ?", input.ID).First(&existing); result.RowsAffected > 0 {
		c.JSON(http.StatusConflict, gin.H{"error": "ID produk sudah digunakan"})
		return
	}

	product := models.Product{
		ID:       input.ID,
		Category: input.Category,
		Name:     input.Name,
		Price:    input.Price,
		Stock:    input.Stock,
		Sold:     0,
		IsLarge:  input.IsLarge,
		ImageURL: input.ImageURL,
	}

	if result := config.DB.Create(&product); result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menambah produk"})
		return
	}

	// Log initial stock
	if product.Stock > 0 {
		ownerIDVal, exists := c.Get("userId")
		var ownerIDPtr *uint
		if exists && ownerIDVal != nil {
			id := ownerIDVal.(uint)
			ownerIDPtr = &id
		}

		config.DB.Create(&models.StockLog{
			ProductID:   product.ID,
			OwnerID:     ownerIDPtr,
			ChangeType:  "addition",
			QtyChanged:  product.Stock,
			FinalStock:  product.Stock,
			Description: "Stok Awal Produk Baru",
		})
	}

	c.JSON(http.StatusCreated, product)
}

// UpdateStock adjusts a product's stock. Owner only.
// PUT /api/products/:id/stock
func UpdateStock(c *gin.Context) {
	productID := c.Param("id")

	var input StockUpdateInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Field 'amount' diperlukan (+ untuk tambah, - untuk kurang)"})
		return
	}

	var product models.Product
	if result := config.DB.Where("id = ?", productID).First(&product); result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Produk tidak ditemukan"})
		return
	}

	newStock := product.Stock + input.Amount
	if newStock < 0 {
		newStock = 0
	}

	actualChange := newStock - product.Stock

	config.DB.Model(&product).Update("stock", newStock)

	// Log stock change
	if actualChange != 0 {
		changeType := "addition"
		reason := "Penambahan Manual Owner"
		if actualChange < 0 {
			changeType = "deduction"
			reason = "Pengurangan Manual Owner"
		}

		ownerIDVal, exists := c.Get("userId")
		var ownerIDPtr *uint
		if exists && ownerIDVal != nil {
			id := ownerIDVal.(uint)
			ownerIDPtr = &id
		}

		config.DB.Create(&models.StockLog{
			ProductID:   product.ID,
			OwnerID:     ownerIDPtr,
			ChangeType:  changeType,
			QtyChanged:  actualChange,
			FinalStock:  newStock,
			Description: reason,
		})
	}

	product.Stock = newStock
	c.JSON(http.StatusOK, gin.H{
		"message": "Stok berhasil diperbarui",
		"product": product,
	})
}

// UpdateProductInput represents the request body for updating an existing product.
type UpdateProductInput struct {
	Category string `json:"category"`
	Name     string `json:"name"`
	Price    int64  `json:"price"`
	Stock    int    `json:"stock"`
	IsLarge  bool   `json:"isLarge"`
	ImageURL string `json:"img"`
}

// UpdateProduct updates an existing product's details. Owner only.
// PUT /api/products/:id
func UpdateProduct(c *gin.Context) {
	productID := c.Param("id")

	var input UpdateProductInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data produk tidak valid"})
		return
	}

	var product models.Product
	if result := config.DB.Where("id = ?", productID).First(&product); result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Produk tidak ditemukan"})
		return
	}

	updates := map[string]interface{}{}
	if input.Name != "" {
		updates["name"] = input.Name
	}
	if input.Category != "" {
		updates["category"] = input.Category
	}
	if input.Price > 0 {
		updates["price"] = input.Price
	}
	updates["stock"] = input.Stock
	updates["is_large"] = input.IsLarge
	if input.ImageURL != "" {
		updates["image_url"] = input.ImageURL
	}

	config.DB.Model(&product).Updates(updates)

	// Reload
	config.DB.First(&product, "id = ?", productID)

	c.JSON(http.StatusOK, gin.H{
		"message": "Produk berhasil diperbarui",
		"product": product,
	})
}

// GetProductByID retrieves a single product by its ID.
// GET /api/products/:id
func GetProductByID(c *gin.Context) {
	productID := c.Param("id")

	var product models.Product
	if result := config.DB.Where("id = ?", productID).First(&product); result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Produk tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, product)
}
