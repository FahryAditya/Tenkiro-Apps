- [x] Update the _airUrl constant to the correct Open-Meteo air quality API domain.
- [x] Remove unused query parameters 'nitrogen_dioxide' and 'ozone' from the 'current' field in getAirQuality method.
- [x] Change the air quality card color for better text visibility and neat appearance.
- [x] Implement Night Sky Visibility Index widget.
- [x] Implement Moon Phase System widget.
- [x] Implement Earth-Sun Relationship widget.

📐 Rancangan Fitur Astronomi & Earth Science (Matang)
🧭 FILOSOFI FITUR
Tenkiro bukan sekadar weather app, tapi:
Aplikasi pemahaman Bumi & Langit berbasis data ilmiah terbuka
Prinsip:
🌱 Open-source friendly
🧠 Ilmiah & dapat dijelaskan
🎨 Visual & intuitif
⚡ Ringan & mobile-first
🧩 STRUKTUR MENU BARU
Salin kode

Home (Cuaca)
Sky
Earth
Air
Events

🌤️ SKY (Astronomi Harian)
1️⃣ Solar Tracker (Matahari)
Tujuan: Memahami siklus harian matahari
Data
Sunrise / Sunset (Open-Meteo)
Latitude / Longitude
Timezone
Perhitungan (Client-side)
Solar elevation angle
Golden hour
Blue hour
Day length
UI
Arc matahari bergerak real-time
Gradien langit dinamis
Timeline horizontal
Nilai tambah
Fotografer
Edukasi
Outdoor activity

2️⃣ Moon Phase System (Bulan)
Tujuan: Aktivitas malam & siklus alam
Data
Moon phase
Illumination (%)
Moon age
Moonrise / Moonset
Sumber
Open-Meteo / perhitungan Julian Date
UI
Bulan animatif
Progress circular phase
Mode malam otomatis

3️⃣ Night Sky Visibility Index ⭐
Fitur andalan Tenkiro
Input Data
Parameter
Sumber
Cloud cover
Open-Meteo
Moon illumination
Moon system
Visibility
Open-Meteo
Humidity
Open-Meteo
Output
Skor 0–100
Kategori:
🔴 Buruk
🟡 Cukup
🟢 Ideal
UI
Gauge meter
Rekomendasi aktivitas

🌍 EARTH (Ilmu Bumi)
4️⃣ Earth–Sun Relationship
Tujuan: Edukasi musim & orbit
Data
Day of year
Solar declination
Visual
Orbit bumi
Musim aktif
Penjelasan singkat

5️⃣ Day–Night Balance
Data
Panjang siang vs malam
Grafik tahunan
UI
Bar chart
Timeline musiman

🌫️ AIR (Atmosfer & Kualitas Udara)
6️⃣ Air Quality Intelligence
Upgrade dari AQI biasa
Data
AQI
PM2.5, PM10, CO, SO₂
Analisis
Dampak kesehatan
Rekomendasi aktivitas luar ruangan
UI
Color-coded cards
Health tips kontekstual

📅 EVENTS (Kalender Astronomi)
7️⃣ Astronomical Events Calendar
Event
Gerhana
Hujan meteor
Solstice / Equinox
Supermoon
Data
NASA open data
Static JSON tahunan
UX
Timeline
Reminder
Event detail page

🧠 ARSITEKTUR DATA (OPEN SOURCE)
Salin kode

Open-Meteo API
     ↓
Data Models
     ↓
Calculation Layer
     ↓
State Management
     ↓
UI Layer
Prinsip
API → hanya ambil data mentah
Semua analisis → client-side
Mudah diuji & dikembangkan

⚙️ STATE MANAGEMENT
Rekomendasi: Riverpod
Kenapa?
Aman async
Mudah cache
Cocok data ilmiah

🎨 UX SYSTEM
Dynamic theme (day/night)
Context-aware UI
Smooth animation (≤ 300ms)
Aksesibilitas (kontras tinggi)