package main

import (
	"fmt"
	"strings"
	"sinar-abadi-backend/config"
	"sinar-abadi-backend/models"
)

func main() {
	config.ConnectDatabase()
	
	var products []models.Product
	config.DB.Find(&products)
	
	fmt.Printf("Updating brands for %d products...\n", len(products))
	
	for _, p := range products {
		name := strings.ToLower(p.Name)
		newBrand := ""
		
		// 1. Semen
		if p.Category == "Semen" {
			if strings.Contains(name, "gresik") {
				newBrand = "Semen Gresik"
			} else if strings.Contains(name, "merah putih") {
				newBrand = "Merah Putih"
			} else if strings.Contains(name, "tiga roda") {
				newBrand = "Tiga Roda"
			} else if strings.Contains(name, "padang") {
				newBrand = "Semen Padang"
			} else if strings.Contains(name, "holcim") {
				newBrand = "Holcim"
			} else if strings.Contains(name, "dynamix") {
				newBrand = "Dynamix"
			} else if strings.Contains(name, "tonasa") {
				newBrand = "Semen Tonasa"
			} else if strings.Contains(name, "baturaja") {
				newBrand = "Semen Baturaja"
			} else if strings.Contains(name, "garuda") {
				newBrand = "Semen Garuda"
			} else if strings.Contains(name, "rajawali") {
				newBrand = "Rajawali"
			} else if strings.Contains(name, "hitam") {
				newBrand = "Semen Hitam"
			} else {
				newBrand = "Semen" // Default generic if not matched
			}
		} else if p.Category == "Cat Tembok" {
			if strings.Contains(name, "avian") {
				newBrand = "Avian"
			} else if strings.Contains(name, "avitex") {
				newBrand = "Avitex"
			} else if strings.Contains(name, "dulux") {
				newBrand = "Dulux"
			} else if strings.Contains(name, "catylac") {
				newBrand = "Catylac"
			} else if strings.Contains(name, "nippon") || strings.Contains(name, "vinilex") {
				newBrand = "Nippon Paint"
			} else if strings.Contains(name, "decolith") {
				newBrand = "Decolith"
			} else if strings.Contains(name, "aquaproof") {
				newBrand = "Aquaproof"
			} else if strings.Contains(name, "no drop") || strings.Contains(name, "nodrop") {
				newBrand = "No Drop"
			} else if strings.Contains(name, "jotun") {
				newBrand = "Jotun"
			} else if strings.Contains(name, "propan") {
				newBrand = "Propan"
			} else if strings.Contains(name, "mowilex") {
				newBrand = "Mowilex"
			} else if strings.Contains(name, "danapaint") {
				newBrand = "Danapaint"
			} else {
				newBrand = "Cat Tembok"
			}
		} else if p.Category == "Perpipaan" || strings.Contains(name, "pipa") {
			if strings.Contains(name, "wavin") {
				newBrand = "Wavin"
			} else if strings.Contains(name, "rucika") {
				newBrand = "Rucika"
			} else if strings.Contains(name, "maspion") {
				newBrand = "Maspion"
			} else if strings.Contains(name, "supramas") {
				newBrand = "Supramas"
			} else if strings.Contains(name, "trilliun") {
				newBrand = "Trilliun"
			} else if strings.Contains(name, "onda") {
				newBrand = "Onda"
			} else if strings.Contains(name, "langgeng") {
				newBrand = "Langgeng"
			} else if strings.Contains(name, "aldebaron") {
				newBrand = "Aldebaron"
			} else {
				newBrand = "Tanpa Merek"
			}
		} else if p.Category == "Perkakas" || p.Category == "Alat Pertukangan" {
			if strings.Contains(name, "tekiro") {
				newBrand = "Tekiro"
			} else if strings.Contains(name, "bosch") {
				newBrand = "Bosch"
			} else if strings.Contains(name, "makita") {
				newBrand = "Makita"
			} else if strings.Contains(name, "stanley") {
				newBrand = "Stanley"
			} else if strings.Contains(name, "krisbow") {
				newBrand = "Krisbow"
			} else if strings.Contains(name, "kenmaster") {
				newBrand = "Kenmaster"
			} else if strings.Contains(name, "ingco") {
				newBrand = "Ingco"
			} else if strings.Contains(name, "ryobi") {
				newBrand = "Ryobi"
			} else if strings.Contains(name, "black & decker") || strings.Contains(name, "black+decker") {
				newBrand = "Black+Decker"
			} else if strings.Contains(name, "dewalt") {
				newBrand = "DeWalt"
			} else {
				newBrand = "Perkakas"
			}
		} else if p.Category == "Pasir" || p.Category == "Batu Bata" || p.Category == "Batu" || p.Category == "Kayu" || p.Category == "Besi" || p.Category == "Baja Ringan" {
			newBrand = "Lokal / Tanpa Merek"
		} else {
			// Generic fallback logic if no specific category matched
			if strings.Contains(name, "krakatau steel") {
				newBrand = "Krakatau Steel"
			} else if strings.Contains(name, "taso") {
				newBrand = "Taso"
			} else if strings.Contains(name, "ykk") {
				newBrand = "YKK AP"
			} else if strings.Contains(name, "toto") {
				newBrand = "TOTO"
			} else if strings.Contains(name, "american standard") {
				newBrand = "American Standard"
			} else if strings.Contains(name, "phillips") || strings.Contains(name, "philips") {
				newBrand = "Philips"
			} else if strings.Contains(name, "panasonic") {
				newBrand = "Panasonic"
			} else if strings.Contains(name, "broco") {
				newBrand = "Broco"
			} else if strings.Contains(name, "sika") {
				newBrand = "Sika"
			} else if strings.Contains(name, "fosroc") {
				newBrand = "Fosroc"
			} else {
				newBrand = "Lokal / Tanpa Merek"
			}
		}
		
		// Additional specific overrides if name matches perfectly
		if p.ID == "P-033" || p.ID == "P-001" {
			newBrand = "Semen Gresik"
		} else if p.ID == "P-002" || p.ID == "P-034" {
			newBrand = "Merah Putih"
		}

		if newBrand != "" {
			updates := map[string]interface{}{}
			updates["brand"] = newBrand
			if err := config.DB.Model(&p).Updates(updates).Error; err != nil {
				fmt.Printf("Error updating %s: %v\n", p.ID, err)
			} else {
				fmt.Printf("Updated %s (%s) - Brand: %s\n", p.ID, p.Name, newBrand)
			}
		}
	}
	fmt.Println("Brand update completed successfully!")
}
