package controllers

import (
	"fmt"
	"math/rand"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"strings"
	"sinar-abadi-backend/config"
	"sinar-abadi-backend/models"
	"sinar-abadi-backend/services"
)

// ---- Request DTOs ----

// CheckoutItemInput represents a single item in the checkout request.
type CheckoutItemInput struct {
	ProductID string `json:"productId" binding:"required"`
	Name      string `json:"name" binding:"required"`
	Qty       int    `json:"qty" binding:"required"`
	Price     int64  `json:"price" binding:"required"`
	Weight    int    `json:"weight"` // weight per unit in grams
	Length    int    `json:"length"` // length in cm
	Width     int    `json:"width"`  // width in cm
	Height    int    `json:"height"` // height in cm
	Color     string `json:"color"`
}

type CheckoutInput struct {
	Phone              string              `json:"phone" binding:"required"` // WhatsApp number
	Address            string              `json:"address" binding:"required"`
	ShippingMethod     string              `json:"shippingMethod" binding:"required"`
	PaymentMethod      string              `json:"paymentMethod" binding:"required"` // Virtual Account, Credit Card
	BiteshipAreaID     string              `json:"biteshipAreaId"`                   // Can be empty for store pickup
	ShippingCost       int64               `json:"shippingCost"`                     // Provided by frontend from Biteship
	CourierCode        string              `json:"courierCode"`                      // e.g. "jne", "sicepat" from Biteship
	CourierServiceCode string              `json:"courierServiceCode"`               // e.g. "reg", "best", "jtr", "gokil" from Biteship
	Items              []CheckoutItemInput `json:"items" binding:"required,min=1"`
	Total              int64               `json:"total" binding:"required"` // Total product cost
}

// StatusUpdateInput represents the request body for updating order status.
type StatusUpdateInput struct {
	Status         string `json:"status"`         // pending | success | refund | cancelled
	ShippingStatus string `json:"shippingStatus"` // shipping status label
}

// ProofUploadInput represents the request body for marking proof as uploaded.
type ProofUploadInput struct {
	ProofUploaded bool   `json:"proofUploaded"`
	ProofUrl      string `json:"proofUrl"`
}

// ---- Helpers ----

// generateOrderID creates an order ID in the format ORD-YYMMDD-XXX.
func generateOrderID() string {
	now := time.Now()
	return fmt.Sprintf("ORD-%s%s%s-%03d",
		fmt.Sprintf("%02d", now.Year()%100),
		fmt.Sprintf("%02d", int(now.Month())),
		fmt.Sprintf("%02d", now.Day()),
		rand.Intn(900)+100,
	)
}

// ---- Handlers ----

// CreateOrder handles customer checkout.
// POST /api/orders
func CreateOrder(c *gin.Context) {
	var input CheckoutInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data checkout tidak lengkap: " + err.Error()})
		return
	}

	// Get the authenticated user ID and username from JWT context
	userID, _ := c.Get("userId")
	username, _ := c.Get("username")

	var customerNameStr string
	var customer models.Customer
	if err := config.DB.Where("id = ?", userID).First(&customer).Error; err == nil && customer.Name != "" {
		customerNameStr = customer.Name
	} else {
		customerNameStr = username.(string)
	}

	orderID := generateOrderID()

	// Validate stock availability and decrement
	tx := config.DB.Begin()
	for _, item := range input.Items {
		var product models.Product
		if result := tx.Where("id = ?", item.ProductID).First(&product); result.Error != nil {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("Produk %s tidak ditemukan", item.ProductID)})
			return
		}

		// Calculate current stock from stock_logs
		currentStock := getStockByProductID(item.ProductID)

		if currentStock < item.Qty {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("Stok %s tidak mencukupi (tersisa %d)", product.Name, currentStock)})
			return
		}
		// Increase sold count only (stock is managed via stock_logs)
		tx.Model(&product).Update("sold", product.Sold+item.Qty)

		// Log stock deduction due to sale
		newStock := currentStock - item.Qty
		tx.Create(&models.StockLog{
			ProductID:   item.ProductID,
			ChangeType:  "deduction",
			QtyChanged:  -item.Qty,
			FinalStock:  newStock,
			Description: fmt.Sprintf("Penjualan (Order %s)", orderID),
		})
	}

	// Build order items
	var orderItems []models.OrderItem
	for _, item := range input.Items {
		// Look up actual product weight and dimensions if not provided
		itemWeight := item.Weight
		itemLength := item.Length
		itemWidth := item.Width
		itemHeight := item.Height

		if itemWeight <= 0 || itemLength <= 0 || itemWidth <= 0 || itemHeight <= 0 {
			var product models.Product
			if err := config.DB.Where("id = ?", item.ProductID).First(&product).Error; err == nil {
				if itemWeight <= 0 { itemWeight = product.Weight }
				if itemLength <= 0 { itemLength = product.Length }
				if itemWidth <= 0 { itemWidth = product.Width }
				if itemHeight <= 0 { itemHeight = product.Height }
			}
		}

		// Final safety check
		if itemLength <= 0 { itemLength = 1 }
		if itemWidth <= 0 { itemWidth = 1 }
		if itemHeight <= 0 { itemHeight = 1 }

		orderItems = append(orderItems, models.OrderItem{
			ProductID: item.ProductID,
			Name:      item.Name,
			Qty:       item.Qty,
			Price:     item.Price,
			Weight:    itemWeight,
			Length:    itemLength,
			Width:     itemWidth,
			Height:    itemHeight,
			Color:     item.Color,
		})
	}

	logisticsSvc := services.NewLogisticsService()
	paymentSvc := services.NewPaymentService()

	// We trust the frontend shippingCost if it's Biteship, otherwise calculate standard
	shippingCost := input.ShippingCost
	if input.BiteshipAreaID == "" && input.ShippingMethod != "Ambil Di Toko" && input.ShippingMethod != "Kurir Toko Sinar Abadi" {
		var err error
		shippingCost, err = logisticsSvc.CalculateShippingCost(input.ShippingMethod, input.Address, orderItems)
		if err != nil {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
	} else if input.ShippingMethod == "Kurir Toko Sinar Abadi" {
		if !strings.Contains(strings.ToLower(input.Address), "malang") {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{"error": "Pengiriman Kurir Toko Sinar Abadi hanya berlaku untuk area Malang"})
			return
		}
	}

	order := models.Order{
		ID:             orderID,
		Date:           time.Now().Format("2006-01-02"),
		CustomerID:     userID.(uint),
		CustomerName:   customerNameStr,
		Phone:          input.Phone,
		Address:        input.Address,
		ShippingMethod: input.ShippingMethod,
		Total:          input.Total + shippingCost,
		Status:         "pending",
		ShippingStatus: "Menunggu Validasi",
		ProofUploaded:  false,
		Items:          orderItems,
	}

	if result := tx.Create(&order); result.Error != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat pesanan"})
		return
	}

	// Create Shipping record
	shipping := models.Shipping{
		OrderID:            orderID,
		ShippingMethodName: input.ShippingMethod,
		TrackingNumber:     input.Phone, // Use Phone as WhatsApp tracking number
		ShippingCost:       shippingCost,
		DestinationAddress: input.Address,
		BiteshipAreaID:     input.BiteshipAreaID,
		CourierCode:        input.CourierCode,
		CourierServiceCode: input.CourierServiceCode,
	}

	if result := tx.Create(&shipping); result.Error != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data logistik"})
		return
	}

	// Initiate Payment
	_, err := paymentSvc.InitiatePayment(orderID, input.PaymentMethod, order.Total)
	if err != nil {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	payment := models.Payment{
		OrderID:       orderID,
		PaymentMethod: input.PaymentMethod,
		AmountPaid:    order.Total,
		PaymentStatus: "Pending",
	}

	if result := tx.Create(&payment); result.Error != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data pembayaran"})
		return
	}

	tx.Commit()

	// Reload with items, shipping, and payment for response
	config.DB.Preload("Items").Preload("Shipping").Preload("Payment").First(&order, "id = ?", order.ID)

	c.JSON(http.StatusCreated, order)
}

// GetOrders returns orders based on the user's role.
// - Customer: only their own orders
// - Admin/Owner: all orders (with optional status filter)
// GET /api/orders?status=pending|success|refund|cancelled
func GetOrders(c *gin.Context) {
	role, _ := c.Get("role")
	userID, _ := c.Get("userId")

	var orders []models.Order
	query := config.DB.Preload("Items").Preload("Shipping").Preload("Payment").Order("created_at DESC")

	// Customers only see their own orders
	if role.(string) == "customer" {
		query = query.Where("customer_id = ?", userID.(uint))
	}

	// Optional status filter (for Admin/Owner dashboard)
	if statusFilter := c.Query("status"); statusFilter != "" && statusFilter != "all" {
		query = query.Where("status = ?", statusFilter)
	}

	if result := query.Find(&orders); result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data pesanan"})
		return
	}

	c.JSON(http.StatusOK, orders)
}

// GetOrderByID retrieves a single order by its ID for tracking.
// GET /api/orders/:id
func GetOrderByID(c *gin.Context) {
	orderID := c.Param("id")

	var order models.Order
	if result := config.DB.Preload("Items").Preload("Shipping").Preload("Payment").Where("id = ?", orderID).First(&order); result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pesanan tidak ditemukan"})
		return
	}

	// If the requester is a customer, ensure they can only view their own orders
	role, _ := c.Get("role")
	userID, _ := c.Get("userId")
	if role.(string) == "customer" && order.CustomerID != userID.(uint) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Anda tidak memiliki akses ke pesanan ini"})
		return
	}

	c.JSON(http.StatusOK, order)
}

// UpdateOrderStatus handles payment validation (Admin) and shipping status updates (Owner).
// PUT /api/orders/:id/status
func UpdateOrderStatus(c *gin.Context) {
	orderID := c.Param("id")

	var input StatusUpdateInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data status tidak valid"})
		return
	}

	var order models.Order
	if result := config.DB.Preload("Items").Preload("Shipping").Where("id = ?", orderID).First(&order); result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pesanan tidak ditemukan"})
		return
	}

	updates := map[string]interface{}{}
	if input.Status != "" {
		updates["status"] = input.Status
	}
	if input.ShippingStatus != "" {
		updates["shipping_status"] = input.ShippingStatus
	}

	if len(updates) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Tidak ada perubahan yang dikirim"})
		return
	}

	// Restore stock if the order is being cancelled
	if input.Status == "cancelled" && order.Status != "cancelled" {
		for _, item := range order.Items {
			var product models.Product
			if err := config.DB.Where("id = ?", item.ProductID).First(&product).Error; err == nil {
				config.DB.Model(&product).Update("sold", product.Sold-item.Qty)
			}
			var currentStock int
			config.DB.Model(&models.StockLog{}).
				Where("product_id = ?", item.ProductID).
				Select("COALESCE(SUM(qty_changed), 0)").
				Scan(&currentStock)
			
			config.DB.Create(&models.StockLog{
				ProductID:   item.ProductID,
				ChangeType:  "addition",
				QtyChanged:  item.Qty,
				FinalStock:  currentStock + item.Qty,
				Description: fmt.Sprintf("Pembatalan Pesanan (Order %s)", order.ID),
			})
		}
	}

	config.DB.Model(&order).Updates(updates)

	// If payment is successful, create an order in Biteship
	if input.Status == "success" {
		var shipping models.Shipping
		if err := config.DB.Where("order_id = ?", order.ID).First(&shipping).Error; err == nil {
			// Check if shipping method uses Biteship
			if shipping.BiteshipAreaID != "" && !strings.Contains(shipping.ShippingMethodName, "Ambil Di Toko") && !strings.Contains(shipping.ShippingMethodName, "Kurir Toko Sinar Abadi") {
				
				// Use stored courier codes from Biteship (courier_code & courier_service_code)
				courierCompany := shipping.CourierCode
				courierType := shipping.CourierServiceCode
				
				// Fallback: if codes are empty (legacy orders), try to parse from display name
				if courierCompany == "" {
					parts := strings.SplitN(shipping.ShippingMethodName, " ", 2)
					courierCompany = strings.ToLower(parts[0])
					if len(parts) > 1 {
						courierType = strings.ToLower(parts[1])
					}
				}

				// Build Items
				var bItems []map[string]interface{}
				config.DB.Preload("Items").First(&order, "id = ?", order.ID)
				for _, it := range order.Items {
					itemWeight := it.Weight
					itemLength := it.Length
					itemWidth := it.Width
					itemHeight := it.Height

					if itemWeight <= 0 || itemLength <= 0 || itemWidth <= 0 || itemHeight <= 0 {
						// Fallback: look up product details from DB
						var prod models.Product
						if err := config.DB.Where("id = ?", it.ProductID).First(&prod).Error; err == nil {
							if itemWeight <= 0 { itemWeight = prod.Weight }
							if itemLength <= 0 { itemLength = prod.Length }
							if itemWidth <= 0 { itemWidth = prod.Width }
							if itemHeight <= 0 { itemHeight = prod.Height }
						}
					}
					
					if itemWeight <= 0 { itemWeight = 1000 } // fallback 1kg if still unknown
					if itemLength <= 0 { itemLength = 1 }
					if itemWidth <= 0 { itemWidth = 1 }
					if itemHeight <= 0 { itemHeight = 1 }

					bItems = append(bItems, map[string]interface{}{
						"name":     it.Name,
						"value":    it.Price,
						"quantity": it.Qty,
						"weight":   itemWeight,
						"length":   itemLength,
						"width":    itemWidth,
						"height":   itemHeight,
					})
				}

				originAreaID := "IDNP11IDNC250IDND2604IDZ65181" // Hardcoded Dampit area
				biteshipResp, err := services.CreateOrder(
					order.ID,
					originAreaID,
					shipping.BiteshipAreaID,
					courierCompany,
					courierType,
					bItems,
					order.CustomerName,
					order.Phone,
					shipping.DestinationAddress,
				)
				if err == nil && biteshipResp != nil {
					// Extract IDs
					biteshipOrderID, _ := biteshipResp["id"].(string)
					
					waybillID := ""
					if courierObj, ok := biteshipResp["courier"].(map[string]interface{}); ok {
						waybillID, _ = courierObj["waybill_id"].(string)
					}

					// Update tracking status
					config.DB.Model(&shipping).Updates(map[string]interface{}{
						"biteship_order_id": biteshipOrderID,
						"waybill_id":        waybillID,
					})
					config.DB.Model(&order).Update("shipping_status", "Kurir Sedang Dijadwalkan")
				}
			}
		}
	}

	// Reload for response
	config.DB.Preload("Items").Preload("Shipping").Preload("Payment").First(&order, "id = ?", order.ID)

	c.JSON(http.StatusOK, gin.H{
		"message": "Status pesanan berhasil diperbarui",
		"order":   order,
	})
}

// UploadProof marks the proof of payment as uploaded.
// PUT /api/orders/:id/proof
func UploadProof(c *gin.Context) {
	orderID := c.Param("id")

	var order models.Order
	if result := config.DB.Where("id = ?", orderID).First(&order); result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pesanan tidak ditemukan"})
		return
	}

	// Verify ownership if customer
	role, _ := c.Get("role")
	userID, _ := c.Get("userId")
	if role.(string) == "customer" && order.CustomerID != userID.(uint) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Anda tidak memiliki akses ke pesanan ini"})
		return
	}

	var input ProofUploadInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	config.DB.Model(&order).Updates(map[string]interface{}{
		"proof_uploaded": true,
		"proof_url":      input.ProofUrl,
	})

	c.JSON(http.StatusOK, gin.H{
		"message": "Bukti pembayaran berhasil diunggah",
	})
}

// CompleteOrderCustomer allows a customer to mark their own shipping order as completed
// PUT /api/orders/:id/complete
func CompleteOrderCustomer(c *gin.Context) {
	orderID := c.Param("id")
	
	// Get userId from token/middleware
	userID, exists := c.Get("userId")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var order models.Order
	if result := config.DB.Where("id = ? AND customer_id = ?", orderID, userID).First(&order); result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pesanan tidak ditemukan atau Anda tidak memiliki akses"})
		return
	}

	if order.Status != "shipping" && order.Status != "SHIPPING" && order.Status != "success" && order.Status != "SUCCESS" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Pesanan tidak dapat diselesaikan pada status ini (" + order.Status + ")"})
		return
	}

	config.DB.Model(&order).Update("status", "COMPLETED")

	c.JSON(http.StatusOK, gin.H{"message": "Pesanan berhasil diselesaikan", "order": order})
}
