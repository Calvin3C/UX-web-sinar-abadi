package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
)

func main() {
	apiKey := os.Getenv("BITESHIP_API_KEY")
	if apiKey == "" {
		fmt.Println("No API Key found")
		return
	}
	reqURL := "https://api.biteship.com/v1/rates/couriers"
	payload := map[string]interface{}{
		"origin_area_id":      "IDNP11IDNC250IDND2604IDZ65181",
		"destination_area_id": "IDNP31IDNC314IDND2240IDZ12430",
		"couriers":            "jne,sicepat,jnt",
		"items": []map[string]interface{}{
			{
				"name": "Test Item",
				"value": 10000,
				"quantity": 1,
				"weight": 1000,
			},
		},
	}
	
	jsonPayload, _ := json.Marshal(payload)
	req, _ := http.NewRequest(http.MethodPost, reqURL, bytes.NewBuffer(jsonPayload))

	req.Header.Set("Authorization", apiKey)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	defer resp.Body.Close()
	
	bodyBytes, _ := io.ReadAll(resp.Body)
	fmt.Printf("Status: %d\nBody: %s\n", resp.StatusCode, string(bodyBytes))
}
