import sqlite3
import json

conn = sqlite3.connect('sinarabadi.db')
cursor = conn.cursor()
cursor.execute("SELECT * FROM shippings ORDER BY id DESC LIMIT 1;")
row = cursor.fetchone()
columns = [description[0] for description in cursor.description]

if row:
    data = dict(zip(columns, row))
    print(json.dumps(data, indent=2))
else:
    print("No records found")
conn.close()
