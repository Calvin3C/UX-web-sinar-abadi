-- 1. Modifikasi tabel stock_logs: JANGAN DROP tabel lama, tambahkan kolom baru
ALTER TABLE stock_logs ADD COLUMN IF NOT EXISTS quantity INTEGER;
ALTER TABLE stock_logs ADD COLUMN IF NOT EXISTS type VARCHAR(20);
ALTER TABLE stock_logs ADD COLUMN IF NOT EXISTS reference_id VARCHAR(255);

-- Ubah constraint kolom lama agar bisa dikosongkan (jika sistem baru tidak mengisinya)
ALTER TABLE stock_logs ALTER COLUMN change_type DROP NOT NULL;
ALTER TABLE stock_logs ALTER COLUMN qty_changed DROP NOT NULL;
ALTER TABLE stock_logs ALTER COLUMN final_stock DROP NOT NULL;

-- 2. Isi kolom quantity dan type untuk data histori lama
-- Mengonversi dari 'addition'/'deduction' ke 'IN'/'OUT' dengan minus/plus
UPDATE stock_logs 
SET 
    quantity = CASE 
        WHEN change_type = 'deduction' THEN -ABS(qty_changed)
        ELSE ABS(qty_changed) 
    END,
    type = CASE 
        WHEN change_type = 'addition' THEN 'IN'
        WHEN change_type = 'deduction' THEN 'OUT'
        ELSE 'ADJUSTMENT'
    END
WHERE type IS NULL;

-- 4. Migrasikan stok inisial untuk produk yang ada stok tapi belum punya histori
INSERT INTO stock_logs (product_id, quantity, type, reference_id)
SELECT id, stock, 'IN', 'INITIAL_STOCK' 
FROM products 
WHERE stock > 0 
AND id NOT IN (SELECT product_id FROM stock_logs);

-- 5. Hapus kolom stock dari tabel products
ALTER TABLE products DROP COLUMN IF EXISTS stock;

-- 6. Buat View v_product_stocks untuk menghitung total stok dari kolom quantity yang baru
CREATE OR REPLACE VIEW v_product_stocks AS
SELECT 
    p.id AS product_id,
    p.name AS product_name,
    COALESCE(SUM(sl.quantity), 0) AS total_stock
FROM 
    products p
LEFT JOIN 
    stock_logs sl ON p.id = sl.product_id
GROUP BY 
    p.id, p.name;
