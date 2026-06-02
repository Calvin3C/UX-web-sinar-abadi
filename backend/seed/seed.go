package seed

import (
	"log"

	"sinar-abadi-backend/models"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// RunSeeder populates the database with initial data if tables are empty.
func RunSeeder(db *gorm.DB) {
	seedUsers(db)
	seedProducts(db)
	seedOrders(db)
}

// ---- CUSTOMERS, ADMINS, OWNERS ----
func seedUsers(db *gorm.DB) {
	var customerCount, adminCount, ownerCount int64
	db.Model(&models.Customer{}).Count(&customerCount)
	db.Model(&models.Admin{}).Count(&adminCount)
	db.Model(&models.Owner{}).Count(&ownerCount)

	if customerCount > 0 && adminCount > 0 && ownerCount > 0 {
		log.Println("⏭️  Users tables already seeded, skipping...")
		return
	}

	hashPw := func(pw string) string {
		h, _ := bcrypt.GenerateFromPassword([]byte(pw), bcrypt.DefaultCost)
		return string(h)
	}

	customers := []models.Customer{
		{Username: "budi", Password: hashPw("123"), Name: "Budi Santoso", IsBlocked: false},
	}
	for _, c := range customers {
		if err := db.Create(&c).Error; err != nil {
			log.Printf("⚠️  Failed to seed customer: %v", err)
		}
	}

	admins := []models.Admin{
		{Username: "admin", Password: hashPw("admin123"), Name: "Admin Operasional", IsBlocked: false},
	}
	for _, a := range admins {
		if err := db.Create(&a).Error; err != nil {
			log.Printf("⚠️  Failed to seed admin: %v", err)
		}
	}

	owners := []models.Owner{
		{Username: "owner", Password: hashPw("owner123"), Name: "Dewan Direksi"},
	}
	for _, o := range owners {
		if err := db.Create(&o).Error; err != nil {
			log.Printf("⚠️  Failed to seed owner: %v", err)
		}
	}

	log.Println("✅ Seeded default customer, admin, and owner")
}

// productWithInitialStock holds product data and its initial stock for seeding.
type productWithInitialStock struct {
	Product      models.Product
	InitialStock int
}

// ---- PRODUCTS ----
func seedProducts(db *gorm.DB) {
	var count int64
	db.Model(&models.Product{}).Count(&count)
	if count > 0 {
		log.Println("⏭️  Products table already seeded, skipping...")
		return
	}

	items := []productWithInitialStock{
		// =====================================================================
		// SEMEN (IsLarge = true)
		// =====================================================================
		{Product: models.Product{ID: "P-001", Category: "Semen", Name: "Semen Gresik 40 kg", Price: 59000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Semen+Gresik"}, InitialStock: 100},
		{Product: models.Product{ID: "P-002", Category: "Semen", Name: "Semen Merah Putih 40 kg", Price: 47000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Semen+Merah+Putih"}, InitialStock: 120},
		{Product: models.Product{ID: "P-003", Category: "Semen", Name: "Semen Singa Merah 40 kg", Price: 45000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Semen+Singa+Merah"}, InitialStock: 100},
		{Product: models.Product{ID: "P-004", Category: "Semen", Name: "Semen Putih Tiga Roda 40 kg", Price: 120000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Semen+Tiga+Roda"}, InitialStock: 60},
		{Product: models.Product{ID: "P-005", Category: "Semen", Name: "Semen Putih Panda 40 kg", Price: 65000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Semen+Panda"}, InitialStock: 80},
		{Product: models.Product{ID: "P-006", Category: "Semen", Name: "Semen Sika Perekat Granit 20 kg", Price: 110000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Semen+Sika"}, InitialStock: 50},
		{Product: models.Product{ID: "P-007", Category: "Semen", Name: "Semen Perekat Bata Ringan Drymix 20 kg", Price: 75000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Drymix"}, InitialStock: 70},
		{Product: models.Product{ID: "P-008", Category: "Semen", Name: "Semen Perekat Bata Ringan Eco 20 kg", Price: 65000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Eco+Bata"}, InitialStock: 70},

		// =====================================================================
		// PLUMBING — Maspion AW (IsLarge = false)
		// =====================================================================
		{Product: models.Product{ID: "P-009", Category: "Perpipaan", Name: "Pipa Maspion 1/2 AW", Price: 35000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_aw.png"}, InitialStock: 200},
		{Product: models.Product{ID: "P-010", Category: "Perpipaan", Name: "Pipa Maspion 3/4 AW", Price: 42000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_aw.png"}, InitialStock: 200},
		{Product: models.Product{ID: "P-011", Category: "Perpipaan", Name: "Pipa Maspion 1 AW", Price: 56000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_aw.png"}, InitialStock: 150},
		{Product: models.Product{ID: "P-012", Category: "Perpipaan", Name: "Pipa Maspion 1 1/4 AW", Price: 74000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_aw.png"}, InitialStock: 100},
		{Product: models.Product{ID: "P-013", Category: "Perpipaan", Name: "Pipa Maspion 1 1/2 AW", Price: 98000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_aw.png"}, InitialStock: 100},
		{Product: models.Product{ID: "P-014", Category: "Perpipaan", Name: "Pipa Maspion 2 AW", Price: 138000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_aw.png"}, InitialStock: 80},
		{Product: models.Product{ID: "P-015", Category: "Perpipaan", Name: "Pipa Maspion 2 1/2 AW", Price: 185000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_aw.png"}, InitialStock: 60},
		{Product: models.Product{ID: "P-016", Category: "Perpipaan", Name: "Pipa Maspion 3 AW", Price: 255000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_aw.png"}, InitialStock: 50},
		{Product: models.Product{ID: "P-017", Category: "Perpipaan", Name: "Pipa Maspion 4 AW", Price: 385000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_aw.png"}, InitialStock: 40},
		{Product: models.Product{ID: "P-018", Category: "Perpipaan", Name: "Pipa Maspion 5 AW", Price: 575000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_aw.png"}, InitialStock: 30},
		{Product: models.Product{ID: "P-019", Category: "Perpipaan", Name: "Pipa Maspion 6 AW", Price: 765000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_aw.png"}, InitialStock: 20},
		{Product: models.Product{ID: "P-020", Category: "Perpipaan", Name: "Pipa Maspion 8 AW", Price: 1275000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_aw.png"}, InitialStock: 15},

		// Maspion C
		{Product: models.Product{ID: "P-021", Category: "Perpipaan", Name: "Pipa Maspion 5/8 C", Price: 9000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_c.png"}, InitialStock: 300},
		{Product: models.Product{ID: "P-022", Category: "Perpipaan", Name: "Pipa Maspion 3/4 C", Price: 16000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_c.png"}, InitialStock: 250},
		{Product: models.Product{ID: "P-023", Category: "Perpipaan", Name: "Pipa Maspion 1 C", Price: 26000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_c.png"}, InitialStock: 200},
		{Product: models.Product{ID: "P-024", Category: "Perpipaan", Name: "Pipa Maspion 1 1/4 C", Price: 31000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_c.png"}, InitialStock: 150},
		{Product: models.Product{ID: "P-025", Category: "Perpipaan", Name: "Pipa Maspion 1 1/2 C", Price: 37000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_c.png"}, InitialStock: 150},
		{Product: models.Product{ID: "P-026", Category: "Perpipaan", Name: "Pipa Maspion 2 C", Price: 58000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_c.png"}, InitialStock: 100},
		{Product: models.Product{ID: "P-027", Category: "Perpipaan", Name: "Pipa Maspion 2 1/2 C", Price: 69000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_c.png"}, InitialStock: 80},
		{Product: models.Product{ID: "P-028", Category: "Perpipaan", Name: "Pipa Maspion 3 C", Price: 79000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_c.png"}, InitialStock: 60},
		{Product: models.Product{ID: "P-029", Category: "Perpipaan", Name: "Pipa Maspion 4 C", Price: 102000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_c.png"}, InitialStock: 50},

		// Maspion D
		{Product: models.Product{ID: "P-030", Category: "Perpipaan", Name: "Pipa Maspion 1 1/4 D", Price: 45000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_d.png"}, InitialStock: 100},
		{Product: models.Product{ID: "P-031", Category: "Perpipaan", Name: "Pipa Maspion 1 1/2 D", Price: 55000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_d.png"}, InitialStock: 100},
		{Product: models.Product{ID: "P-032", Category: "Perpipaan", Name: "Pipa Maspion 2 D", Price: 68000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_d.png"}, InitialStock: 80},
		{Product: models.Product{ID: "P-033", Category: "Perpipaan", Name: "Pipa Maspion 2 1/2 D", Price: 98000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_d.png"}, InitialStock: 60},
		{Product: models.Product{ID: "P-034", Category: "Perpipaan", Name: "Pipa Maspion 3 D", Price: 137000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_d.png"}, InitialStock: 50},
		{Product: models.Product{ID: "P-035", Category: "Perpipaan", Name: "Pipa Maspion 4 D", Price: 189000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_d.png"}, InitialStock: 40},
		{Product: models.Product{ID: "P-036", Category: "Perpipaan", Name: "Pipa Maspion 5 D", Price: 320000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_d.png"}, InitialStock: 30},
		{Product: models.Product{ID: "P-037", Category: "Perpipaan", Name: "Pipa Maspion 6 D", Price: 410000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_d.png"}, InitialStock: 20},
		{Product: models.Product{ID: "P-038", Category: "Perpipaan", Name: "Pipa Maspion 8 D", Price: 730000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_maspion_d.png"}, InitialStock: 15},

		// Rucika AW
		{Product: models.Product{ID: "P-039", Category: "Perpipaan", Name: "Pipa Rucika 1/2 AW", Price: 32000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_rucika_aw.png"}, InitialStock: 200},
		{Product: models.Product{ID: "P-040", Category: "Perpipaan", Name: "Pipa Rucika 3/4 AW", Price: 42000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_rucika_aw.png"}, InitialStock: 200},
		{Product: models.Product{ID: "P-041", Category: "Perpipaan", Name: "Pipa Rucika 1 AW", Price: 55000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_rucika_aw.png"}, InitialStock: 150},
		{Product: models.Product{ID: "P-042", Category: "Perpipaan", Name: "Pipa Rucika 1 1/4 AW", Price: 74000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_rucika_aw.png"}, InitialStock: 100},
		{Product: models.Product{ID: "P-043", Category: "Perpipaan", Name: "Pipa Rucika 1 1/2 AW", Price: 92000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_rucika_aw.png"}, InitialStock: 100},
		{Product: models.Product{ID: "P-044", Category: "Perpipaan", Name: "Pipa Rucika 2 AW", Price: 128000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_rucika_aw.png"}, InitialStock: 80},
		{Product: models.Product{ID: "P-045", Category: "Perpipaan", Name: "Pipa Rucika 2 1/2 AW", Price: 175000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_rucika_aw.png"}, InitialStock: 60},
		{Product: models.Product{ID: "P-046", Category: "Perpipaan", Name: "Pipa Rucika 3 AW", Price: 255000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_rucika_aw.png"}, InitialStock: 50},
		{Product: models.Product{ID: "P-047", Category: "Perpipaan", Name: "Pipa Rucika 4 AW", Price: 385000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_rucika_aw.png"}, InitialStock: 40},
		{Product: models.Product{ID: "P-048", Category: "Perpipaan", Name: "Pipa Rucika 5 AW", Price: 595000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_rucika_aw.png"}, InitialStock: 25},
		{Product: models.Product{ID: "P-049", Category: "Perpipaan", Name: "Pipa Rucika 6 AW", Price: 775000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_rucika_aw.png"}, InitialStock: 20},
		{Product: models.Product{ID: "P-050", Category: "Perpipaan", Name: "Pipa Rucika 8 AW", Price: 1325000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/pipa_rucika_aw.png"}, InitialStock: 10},

		// =====================================================================
		// CAT TEMBOK / PAINT (IsLarge = false)
		// =====================================================================
		{Product: models.Product{ID: "P-051", Category: "Cat Tembok", Name: "Decolith 5 kg", Price: 145000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_decolith.png"}, InitialStock: 100},
		{Product: models.Product{ID: "P-052", Category: "Cat Tembok", Name: "Decolith 25 kg", Price: 725000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_decolith.png"}, InitialStock: 40},
		{Product: models.Product{ID: "P-053", Category: "Cat Tembok", Name: "Avitex 5 kg", Price: 155000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_avitex.png"}, InitialStock: 100},
		{Product: models.Product{ID: "P-054", Category: "Cat Tembok", Name: "Avitex 25 kg", Price: 775000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_avitex.png"}, InitialStock: 35},
		{Product: models.Product{ID: "P-055", Category: "Cat Tembok", Name: "No. Drop 4 kg", Price: 245000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_nodrop.png"}, InitialStock: 60},
		{Product: models.Product{ID: "P-056", Category: "Cat Tembok", Name: "No. Drop 20 kg", Price: 1225000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_nodrop.png"}, InitialStock: 20},
		{Product: models.Product{ID: "P-057", Category: "Cat Tembok", Name: "Aquaproof 4 kg", Price: 265000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_aquaproof.png"}, InitialStock: 50},
		{Product: models.Product{ID: "P-058", Category: "Cat Tembok", Name: "Aquaproof 20 kg", Price: 1275000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_aquaproof.png"}, InitialStock: 15},
		{Product: models.Product{ID: "P-059", Category: "Cat Tembok", Name: "Aries 5 kg", Price: 70000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_aries.png"}, InitialStock: 120},
		{Product: models.Product{ID: "P-060", Category: "Cat Tembok", Name: "Aries 20 kg", Price: 280000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_aries.png"}, InitialStock: 40},

		// =====================================================================
		// CAT KAYU (IsLarge = false)
		// =====================================================================
		{Product: models.Product{ID: "P-061", Category: "Cat Kayu", Name: "Emco Warna Standart 1 kg", Price: 85000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_emco.png"}, InitialStock: 80},
		{Product: models.Product{ID: "P-062", Category: "Cat Kayu", Name: "Emco Warna Standart 0.5 kg", Price: 47500, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_emco.png"}, InitialStock: 100},
		{Product: models.Product{ID: "P-063", Category: "Cat Kayu", Name: "Emco Warna Gunung 1 kg", Price: 95000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_emco.png"}, InitialStock: 60},
		{Product: models.Product{ID: "P-064", Category: "Cat Kayu", Name: "Emco Warna Gunung 0.5 kg", Price: 55000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_emco.png"}, InitialStock: 80},
		{Product: models.Product{ID: "P-065", Category: "Cat Kayu", Name: "Emco Warna Bintang 1 kg", Price: 102000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_emco.png"}, InitialStock: 50},
		{Product: models.Product{ID: "P-066", Category: "Cat Kayu", Name: "Emco Warna Bintang 0.5 kg", Price: 60000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_emco.png"}, InitialStock: 70},
		{Product: models.Product{ID: "P-067", Category: "Cat Kayu", Name: "Avian 1 kg", Price: 85000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_avian.png"}, InitialStock: 80},
		{Product: models.Product{ID: "P-068", Category: "Cat Kayu", Name: "Avian 0.5 kg", Price: 47500, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/cat_avian.png"}, InitialStock: 100},

		// =====================================================================
		// BESI BETON (IsLarge = true)
		// =====================================================================
		{Product: models.Product{ID: "P-069", Category: "Besi Beton", Name: "Besi Beton 6 SNI", Price: 28000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/374151/white?text=Besi+6+SNI"}, InitialStock: 200},
		{Product: models.Product{ID: "P-070", Category: "Besi Beton", Name: "Besi Beton 8 SNI", Price: 46000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/374151/white?text=Besi+8+SNI"}, InitialStock: 150},
		{Product: models.Product{ID: "P-071", Category: "Besi Beton", Name: "Besi Beton 10 SNI", Price: 71000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/374151/white?text=Besi+10+SNI"}, InitialStock: 120},
		{Product: models.Product{ID: "P-072", Category: "Besi Beton", Name: "Besi Beton 12 SNI", Price: 105000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/374151/white?text=Besi+12+SNI"}, InitialStock: 100},
		{Product: models.Product{ID: "P-073", Category: "Besi Beton", Name: "Besi Beton 14 SNI", Price: 134000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/374151/white?text=Besi+14+SNI"}, InitialStock: 80},
		{Product: models.Product{ID: "P-074", Category: "Besi Beton", Name: "Besi Beton 16 SNI", Price: 195000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/374151/white?text=Besi+16+SNI"}, InitialStock: 60},

		// =====================================================================
		// KLOSET (IsLarge = true)
		// =====================================================================
		{Product: models.Product{ID: "P-075", Category: "Kloset", Name: "Kloset Jongkok INA", Price: 210000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Kloset+INA"}, InitialStock: 30},
		{Product: models.Product{ID: "P-076", Category: "Kloset", Name: "Kloset Jongkok Triliun", Price: 205000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Kloset+Triliun"}, InitialStock: 30},
		{Product: models.Product{ID: "P-077", Category: "Kloset", Name: "Kloset Jongkok Duty", Price: 145000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Kloset+Duty"}, InitialStock: 40},
		{Product: models.Product{ID: "P-078", Category: "Kloset", Name: "Monoblok INA", Price: 1550000, Sold: 0, IsLarge: true, ImageURL: "http://localhost:8000/images/products/monoblok.png"}, InitialStock: 10},
		{Product: models.Product{ID: "P-079", Category: "Kloset", Name: "Monoblok Triliun", Price: 1525000, Sold: 0, IsLarge: true, ImageURL: "http://localhost:8000/images/products/monoblok.png"}, InitialStock: 10},
		{Product: models.Product{ID: "P-080", Category: "Kloset", Name: "Monoblok Volk", Price: 1250000, Sold: 0, IsLarge: true, ImageURL: "http://localhost:8000/images/products/monoblok.png"}, InitialStock: 12},

		// =====================================================================
		// TOOLS AND MACHINERY (IsLarge = false)
		// =====================================================================
		{Product: models.Product{ID: "P-081", Category: "Perkakas", Name: "Mesin Pasrah Modern M2900", Price: 495000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Pasrah+M2900"}, InitialStock: 15},
		{Product: models.Product{ID: "P-082", Category: "Perkakas", Name: "Mesin Pasrah Modern M2950", Price: 475000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Pasrah+M2950"}, InitialStock: 15},
		{Product: models.Product{ID: "P-083", Category: "Perkakas", Name: "Mesin Bor Modern M2100", Price: 295000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Bor+M2100"}, InitialStock: 20},
		{Product: models.Product{ID: "P-084", Category: "Perkakas", Name: "Mesin Bor Modern M2130", Price: 395000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/P-084.png"}, InitialStock: 15},
		{Product: models.Product{ID: "P-085", Category: "Perkakas", Name: "Mesin Gerinda Modern M2350", Price: 325000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/P-085.png"}, InitialStock: 18},
		{Product: models.Product{ID: "P-086", Category: "Perkakas", Name: "Mesin Profil Modern M2700", Price: 425000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/P-086.png"}, InitialStock: 12},
		{Product: models.Product{ID: "P-087", Category: "Perkakas", Name: "Mesin Gergaji Modern M2600", Price: 625000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/P-087.png"}, InitialStock: 10},
		{Product: models.Product{ID: "P-088", Category: "Perkakas", Name: "Meteran Tukang 3 m", Price: 25000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/meteran_tukang.png"}, InitialStock: 200},
		{Product: models.Product{ID: "P-089", Category: "Perkakas", Name: "Meteran Tukang 5 m", Price: 35000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/meteran_tukang.png"}, InitialStock: 200},
		{Product: models.Product{ID: "P-090", Category: "Perkakas", Name: "Meteran Tukang 7.5 m", Price: 55000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/meteran_tukang.png"}, InitialStock: 150},
		{Product: models.Product{ID: "P-091", Category: "Perkakas", Name: "Meteran Tukang 10 m", Price: 55000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/meteran_tukang.png"}, InitialStock: 150},
		{Product: models.Product{ID: "P-092", Category: "Perkakas", Name: "Palu Tukang Supit 8 oz", Price: 35000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Palu+8oz"}, InitialStock: 100},
		{Product: models.Product{ID: "P-093", Category: "Perkakas", Name: "Palu Tukang Supit 12 oz", Price: 45000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Palu+12oz"}, InitialStock: 100},
		{Product: models.Product{ID: "P-094", Category: "Perkakas", Name: "Palu Tukang Kotak 200 gram", Price: 35000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Palu+200g"}, InitialStock: 100},
		{Product: models.Product{ID: "P-095", Category: "Perkakas", Name: "Palu Tukang Kotak 300 gram", Price: 45000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Palu+300g"}, InitialStock: 100},

		// =====================================================================
		// ELECTRICAL (IsLarge = false)
		// =====================================================================
		{Product: models.Product{ID: "P-096", Category: "Listrik", Name: "Lampu Philips LED 5 Watt", Price: 25000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/d97706/white?text=Philips+5W"}, InitialStock: 300},
		{Product: models.Product{ID: "P-097", Category: "Listrik", Name: "Lampu Philips LED 7 Watt", Price: 29000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/d97706/white?text=Philips+7W"}, InitialStock: 300},
		{Product: models.Product{ID: "P-098", Category: "Listrik", Name: "Lampu Philips LED 9 Watt", Price: 35000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/d97706/white?text=Philips+9W"}, InitialStock: 250},
		{Product: models.Product{ID: "P-099", Category: "Listrik", Name: "Lampu Philips LED 11 Watt", Price: 42500, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/d97706/white?text=Philips+11W"}, InitialStock: 200},
		{Product: models.Product{ID: "P-100", Category: "Listrik", Name: "Lampu Philips LED 13 Watt", Price: 49500, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/d97706/white?text=Philips+13W"}, InitialStock: 200},

		// =====================================================================
		// KUAS CAT (IsLarge = false)
		// =====================================================================
		{Product: models.Product{ID: "P-101", Category: "Kuas Cat", Name: "Kuas Eterna 1 Inch", Price: 7000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Kuas+1in"}, InitialStock: 300},
		{Product: models.Product{ID: "P-102", Category: "Kuas Cat", Name: "Kuas Eterna 1.5 Inch", Price: 10000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Kuas+1.5in"}, InitialStock: 300},
		{Product: models.Product{ID: "P-103", Category: "Kuas Cat", Name: "Kuas Eterna 2 Inch", Price: 12000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Kuas+2in"}, InitialStock: 250},
		{Product: models.Product{ID: "P-104", Category: "Kuas Cat", Name: "Kuas Eterna 2.5 Inch", Price: 15000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Kuas+2.5in"}, InitialStock: 250},
		{Product: models.Product{ID: "P-105", Category: "Kuas Cat", Name: "Kuas Eterna 3 Inch", Price: 18000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Kuas+3in"}, InitialStock: 200},
		{Product: models.Product{ID: "P-106", Category: "Kuas Cat", Name: "Kuas Eterna 4 Inch", Price: 25000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Kuas+4in"}, InitialStock: 200},
		{Product: models.Product{ID: "P-107", Category: "Kuas Cat", Name: "Kuas Eterna 5 Inch", Price: 30000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Kuas+5in"}, InitialStock: 150},
		{Product: models.Product{ID: "P-108", Category: "Kuas Cat", Name: "Kuas Eterna 6 Inch", Price: 35000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Kuas+6in"}, InitialStock: 150},
		{Product: models.Product{ID: "P-109", Category: "Kuas Cat", Name: "Kuas Roll Eterna 9 Inch", Price: 30000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Roll+Eterna+9in"}, InitialStock: 100},
		{Product: models.Product{ID: "P-110", Category: "Kuas Cat", Name: "Kuas Roll 4 Inch", Price: 15000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Roll+4in"}, InitialStock: 150},
		{Product: models.Product{ID: "P-111", Category: "Kuas Cat", Name: "Kuas Roll Imundex 9 Inch", Price: 30000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Roll+Imundex+9in"}, InitialStock: 100},
		{Product: models.Product{ID: "P-112", Category: "Kuas Cat", Name: "Kuas Roll Imundex 7 Inch", Price: 25000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Roll+Imundex+7in"}, InitialStock: 120},

		// =====================================================================
		// KUNCI PINTU (IsLarge = false)
		// =====================================================================
		{Product: models.Product{ID: "P-113", Category: "Kunci Pintu", Name: "Kunci Pintu Zeona Besar", Price: 175000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Zeona+Besar"}, InitialStock: 50},
		{Product: models.Product{ID: "P-114", Category: "Kunci Pintu", Name: "Kunci Pintu Zeona Tanggung", Price: 110000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Zeona+Tanggung"}, InitialStock: 60},
		{Product: models.Product{ID: "P-115", Category: "Kunci Pintu", Name: "Kunci Pintu WanLi Kecil", Price: 75000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/1e293b/white?text=WanLi+Kecil"}, InitialStock: 80},
		{Product: models.Product{ID: "P-116", Category: "Kunci Pintu", Name: "Kunci Pintu Muller Besar", Price: 325000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Muller+Besar"}, InitialStock: 30},
		{Product: models.Product{ID: "P-117", Category: "Kunci Pintu", Name: "Kunci Pintu Muller Tanggung", Price: 245000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Muller+Tanggung"}, InitialStock: 40},
		{Product: models.Product{ID: "P-118", Category: "Kunci Pintu", Name: "Kunci Pintu Kuda Besar", Price: 125000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Kuda+Besar"}, InitialStock: 60},
		{Product: models.Product{ID: "P-119", Category: "Kunci Pintu", Name: "Kunci Pintu Kuda Kecil", Price: 95000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Kuda+Kecil"}, InitialStock: 70},

		// =====================================================================
		// ENGSEL (IsLarge = false)
		// =====================================================================
		{Product: models.Product{ID: "P-120", Category: "Engsel", Name: "Engsel Pintu Muller 5 Inch", Price: 95000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/64748b/white?text=Engsel+Muller+5in"}, InitialStock: 100},
		{Product: models.Product{ID: "P-121", Category: "Engsel", Name: "Engsel Pintu Muller 4 Inch", Price: 75000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/64748b/white?text=Engsel+Muller+4in"}, InitialStock: 100},
		{Product: models.Product{ID: "P-122", Category: "Engsel", Name: "Engsel Pintu Muller 3 Inch", Price: 45000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/64748b/white?text=Engsel+Muller+3in"}, InitialStock: 120},
		{Product: models.Product{ID: "P-123", Category: "Engsel", Name: "Engsel Pintu Nishio 5 Inch", Price: 45000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/64748b/white?text=Engsel+Nishio+5in"}, InitialStock: 100},
		{Product: models.Product{ID: "P-124", Category: "Engsel", Name: "Engsel Pintu Nishio 4 Inch", Price: 35000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/64748b/white?text=Engsel+Nishio+4in"}, InitialStock: 120},
		{Product: models.Product{ID: "P-125", Category: "Engsel", Name: "Engsel Pintu Nishio 3 Inch", Price: 20000, Sold: 0, IsLarge: false, ImageURL: "https://placehold.co/400x300/64748b/white?text=Engsel+Nishio+3in"}, InitialStock: 150},
		{Product: models.Product{ID: "P-126", Category: "Engsel", Name: "Engsel Lemari Tipis 3 Inch", Price: 10000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/engsel_lemari.png"}, InitialStock: 200},
		{Product: models.Product{ID: "P-127", Category: "Engsel", Name: "Engsel Lemari Tipis 2.5 Inch", Price: 8000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/engsel_lemari.png"}, InitialStock: 200},
		{Product: models.Product{ID: "P-128", Category: "Engsel", Name: "Engsel Lemari Tipis 2 Inch", Price: 7000, Sold: 0, IsLarge: false, ImageURL: "http://localhost:8000/images/products/engsel_lemari.png"}, InitialStock: 250},

		// =====================================================================
		// KERAMIK & GRANITE (IsLarge = true)
		// =====================================================================
		{Product: models.Product{ID: "P-129", Category: "Keramik & Granite", Name: "Keramik Lantai 40x40 cm", Price: 55000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Keramik+40x40"}, InitialStock: 200},
		{Product: models.Product{ID: "P-130", Category: "Keramik & Granite", Name: "Keramik Lantai 50x50 cm", Price: 65000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Keramik+50x50"}, InitialStock: 180},
		{Product: models.Product{ID: "P-131", Category: "Keramik & Granite", Name: "Keramik Lantai 60x60 cm", Price: 135000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Keramik+60x60"}, InitialStock: 100},
		{Product: models.Product{ID: "P-132", Category: "Keramik & Granite", Name: "Keramik Dinding 25x40 cm", Price: 65000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Keramik+25x40"}, InitialStock: 150},
		{Product: models.Product{ID: "P-133", Category: "Keramik & Granite", Name: "Keramik Dinding 25x50 cm", Price: 75000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Keramik+25x50"}, InitialStock: 130},
		{Product: models.Product{ID: "P-134", Category: "Keramik & Granite", Name: "Keramik Dinding 30x60 cm", Price: 90000, Sold: 0, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Keramik+30x60"}, InitialStock: 100},
		{Product: models.Product{ID: "P-135", Category: "Keramik & Granite", Name: "Granite Polos 60x60 cm", Price: 145000, Sold: 0, IsLarge: true, ImageURL: "http://localhost:8000/images/products/granite_tile.png"}, InitialStock: 80},
		{Product: models.Product{ID: "P-136", Category: "Keramik & Granite", Name: "Granite Motif 60x60 cm", Price: 165000, Sold: 0, IsLarge: true, ImageURL: "http://localhost:8000/images/products/granite_tile.png"}, InitialStock: 70},
		{Product: models.Product{ID: "P-137", Category: "Keramik & Granite", Name: "Granite Warna Gelap 60x60 cm", Price: 255000, Sold: 0, IsLarge: true, ImageURL: "http://localhost:8000/images/products/granite_tile.png"}, InitialStock: 50},
	}

	// Create products and their initial stock logs
	for _, item := range items {
		db.Create(&item.Product)

		// Record initial stock in stock_logs
		if item.InitialStock > 0 {
			db.Create(&models.StockLog{
				ProductID:   item.Product.ID,
				ChangeType:  "addition",
				QtyChanged:  item.InitialStock,
				FinalStock:  item.InitialStock,
				Description: "Stok Awal (Seeder)",
			})
		}
	}
	log.Printf("✅ Seeded %d products with initial stock logs\n", len(items))
}

// ---- ORDERS ----
func seedOrders(db *gorm.DB) {
	var count int64
	db.Model(&models.Order{}).Count(&count)
	if count > 0 {
		log.Println("⏭️  Orders table already seeded, skipping...")
		return
	}

	// Get budi's customer ID
	var budi models.Customer
	if result := db.Where("username = ?", "budi").First(&budi); result.Error != nil {
		log.Println("⚠️  Could not find user 'budi' for order seeding")
		return
	}

	orders := []models.Order{
		{
			ID:             "ORD-260401-081",
			Date:           "2026-04-01",
			CustomerID:     budi.ID,
			CustomerName:   "budi",
			Phone:          "081234567890",
			Address:        "Jl. Merdeka, Malang",
			ShippingMethod: "Kurir Toko Sinar Abadi",
			Total:          854700,
			Status:         "success",
			ShippingStatus: "Selesai",
			ProofUploaded:  true,
			Items: []models.OrderItem{
				{ProductID: "P-096", Name: "Lampu Philips LED 5 Watt", Qty: 2, Price: 385000},
			},
		},
		{
			ID:             "ORD-260402-309",
			Date:           "2026-04-02",
			CustomerID:     budi.ID,
			CustomerName:   "budi",
			Phone:          "081234567890",
			Address:        "Toko Sinar Abadi",
			ShippingMethod: "Ambil di Toko",
			Total:          721500,
			Status:         "pending",
			ShippingStatus: "Menunggu Validasi",
			ProofUploaded:  true,
			Items: []models.OrderItem{
				{ProductID: "P-001", Name: "Semen Gresik 40 kg", Qty: 10, Price: 59000},
			},
		},
	}

	for _, o := range orders {
		db.Create(&o)
	}
	log.Println("✅ Seeded 2 sample orders")
}
