package main

import (
	"log"
	"os"
	"strings"
	"time"

	"sinar-abadi-backend/config"
	"sinar-abadi-backend/controllers"
	"sinar-abadi-backend/middleware"
	"sinar-abadi-backend/models"
	"sinar-abadi-backend/seed"
	"sinar-abadi-backend/services"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	_ = godotenv.Load()

	// Connect to PostgreSQL
	config.ConnectDatabase()

	// Auto-migrate all models
	if err := config.DB.AutoMigrate(
		&models.Customer{},
		&models.Admin{},
		&models.Owner{},
		&models.Product{},
		&models.StockLog{},
		&models.Order{},
		&models.OrderItem{},

		&models.Shipping{},
		&models.Payment{},
		&models.CustomerAddress{},
	); err != nil {
		log.Fatalf("❌ Auto-migration failed: %v", err)
	}
	log.Println("✅ Database migration completed")

	// Run seeder (only seeds if tables are empty)
	seed.RunSeeder(config.DB)

	// Initialize Gin router
	r := gin.Default()

	// CORS configuration — allow all origins for development
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: false,
		MaxAge:           12 * time.Hour,
	}))

	// ==================================================================
	// API Routes
	// ==================================================================
	api := r.Group("/api")

	// --- Auth (Public) ---
	api.POST("/register", controllers.Register)
	api.POST("/login", controllers.Login)

	// --- Products ---
	api.GET("/products", controllers.GetProducts) // Public: list with search, filter, sort
	api.GET("/products/:id", controllers.GetProductByID) // Public: product detail

	// Protected product routes
	productAuth := api.Group("/products")
	productAuth.Use(middleware.AuthRequired())
	{
		productAuth.POST("", middleware.RoleRequired("admin", "owner"), controllers.CreateProduct)
		productAuth.PUT("/:id/stock", middleware.RoleRequired("owner"), controllers.UpdateStock)
		productAuth.PUT("/:id", middleware.RoleRequired("admin", "owner"), controllers.UpdateProduct)

		// Variant management (Owner only)
		productAuth.POST("/:id/variants", middleware.RoleRequired("owner"), controllers.CreateVariant)
		productAuth.DELETE("/:id/variants/:variantId", middleware.RoleRequired("owner"), controllers.DeleteVariant)
	}

	// --- Orders (All require auth) ---
	orderRoutes := api.Group("/orders")
	orderRoutes.Use(middleware.AuthRequired())
	{
		orderRoutes.POST("", middleware.RoleRequired("customer"), controllers.CreateOrder)
		orderRoutes.GET("", controllers.GetOrders) // role-based filtering inside handler
		orderRoutes.GET("/:id", controllers.GetOrderByID)
		orderRoutes.PUT("/:id/status", middleware.RoleRequired("admin", "owner"), controllers.UpdateOrderStatus)
		orderRoutes.PUT("/:id/cancel", middleware.RoleRequired("customer"), controllers.CancelOrderCustomer)
		orderRoutes.PUT("/:id/complete", middleware.RoleRequired("customer"), controllers.CompleteOrderCustomer)
		orderRoutes.PUT("/:id/proof", middleware.RoleRequired("customer"), controllers.UploadProof)
	}

	// --- Addresses (Customer only) ---
	addressRoutes := api.Group("/addresses")
	addressRoutes.Use(middleware.AuthRequired())
	{
		addressRoutes.GET("", middleware.RoleRequired("customer"), controllers.GetCustomerAddresses)
		addressRoutes.POST("", middleware.RoleRequired("customer"), controllers.CreateCustomerAddress)
		addressRoutes.PUT("/:id", middleware.RoleRequired("customer"), controllers.UpdateCustomerAddress)
		addressRoutes.DELETE("/:id", middleware.RoleRequired("customer"), controllers.DeleteCustomerAddress)
	}

	// --- Biteship (Public/Customer) ---
	api.GET("/biteship/maps", controllers.SearchBiteshipAreas)
	api.POST("/biteship/rates", controllers.CalculateRates)
	api.POST("/biteship/webhook", controllers.BiteshipWebhook)
	api.GET("/biteship/tracking/:id", controllers.GetTracking)

	// --- Midtrans Payment Webhook (Public) ---
	api.POST("/midtrans/webhook", controllers.MidtransWebhook)

	// --- Users (Admin/Owner) ---
	userRoutes := api.Group("/users")
	userRoutes.Use(middleware.AuthRequired())
	{
		// Profile (All authenticated users)
		userRoutes.GET("/profile", controllers.GetProfile)
		userRoutes.PUT("/profile", controllers.UpdateProfile)

		userRoutes.GET("", middleware.RoleRequired("admin", "owner"), controllers.GetCustomers)

		// Admin management (Owner only)
		userRoutes.GET("/admins", middleware.RoleRequired("owner"), controllers.GetAdmins)
		userRoutes.POST("/admins", middleware.RoleRequired("owner"), controllers.CreateAdmin)
		userRoutes.PUT("/admins/:username", middleware.RoleRequired("owner"), controllers.UpdateAdmin)
		userRoutes.DELETE("/admins/:username", middleware.RoleRequired("owner"), controllers.DeleteAdmin)
	}

	// ==================================================================
	// Health check
	// ==================================================================
	api.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "ok",
			"service": "Sinar Abadi Backend API",
			"version": "1.0.0",
		})
	})

	// ==================================================================
	// Background Worker for Syncing Order Status with Biteship
	// ==================================================================
	go func() {
		// Wait a bit before starting
		time.Sleep(10 * time.Second)
		for {
			// Find all orders that are currently "success" or "shipping"
			var activeOrders []models.Order
			if err := config.DB.Where("status IN ?", []string{"success", "SUCCESS", "shipping", "SHIPPING"}).Find(&activeOrders).Error; err == nil {
				for _, order := range activeOrders {
					// Check if there is a shipping record with BiteshipOrderID
					var shipping models.Shipping
					if err := config.DB.Where("order_id = ?", order.ID).First(&shipping).Error; err == nil && shipping.BiteshipOrderID != "" {
						// Fetch latest tracking from Biteship
						trackRes, err := services.TrackOrder(shipping.BiteshipOrderID)
						if err == nil && trackRes["success"] == true {
							if data, ok := trackRes["data"].(map[string]interface{}); ok {
								statusRaw, _ := data["status"].(string)
								if statusRaw != "" {
									// Map Biteship status to Sinar Abadi
									newStatus := order.Status
									if statusRaw == "picking_up" || statusRaw == "allocated" || statusRaw == "placed" {
										// Kept as success (Diproses)
										newStatus = "success"
									} else if statusRaw == "picked" || statusRaw == "dropping_off" {
										// Moved to shipping (Dikirim)
										newStatus = "shipping"
									} else if statusRaw == "delivered" {
										// Moved to completed (Selesai)
										newStatus = "completed"
									} else if statusRaw == "cancelled" {
										newStatus = "cancelled"
									}
									
									// If status changed, update DB
									if newStatus != order.Status && newStatus != strings.ToLower(order.Status) {
										config.DB.Model(&order).Update("status", newStatus)
									}
								}
							}
						}
					}
				}
			}
			// Sync every 2 minutes
			time.Sleep(2 * time.Minute)
		}
	}()

	// Start server
	port := os.Getenv("SERVER_PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("🚀 Sinar Abadi API Server running on http://localhost:%s", port)
	log.Printf("📋 API Base URL: http://localhost:%s/api", port)

	if err := r.Run(":" + port); err != nil {
		log.Fatalf("❌ Failed to start server: %v", err)
	}
}
