#!/bin/bash

# Tentukan path file zone lu (sesuaikan jika berbeda)
ZONE_FILE="/etc/bind/k-39/k-39.com"

echo "=========================================================="
echo "       INJECT TXT RECORD OTOMATIS KE FILE ZONE BIND9      "
echo "=========================================================="

if [ ! -f "$ZONE_FILE" ]; then
    echo -e "\e[31mError: File zone $ZONE_FILE tidak ditemukan!\e[0m"
    exit 1
fi

# Cek apakah TXT record sudah pernah di-inject sebelumnya biar nggak duplikat
if grep -q "TXT" "$ZONE_FILE"; then
    echo -e "\e[33m[INFO] Record TXT sudah ada di dalam file zone. Melanjutkan update/reload...\e[0m"
else
    echo -e "\nMenambahkan TXT record untuk alpha, beta, gamma, delta, epsilon..."
    cat << 'EOF' >> "$ZONE_FILE"

; --- Otomasi Tambahan TXT Record (Soal 17) ---
alpha   IN  TXT "alpha"
beta    IN  TXT "beta"
gamma   IN  TXT "gamma"
delta   IN  TXT "delta"
epsilon IN  TXT "epsilon"
EOF
    echo -e "\e[32m[SUKSES] Baris TXT berhasil disuntikkan ke bagian bawah file.\e[0m"
fi

# Menaikkan serial SOA secara otomatis (mencari baris serial dan menaikkan nilainya)
# Mengambil angka serial lama, lalu ditambah 1
OLD_SERIAL=$(grep -E "[0-9]{10}\s+;\s*Serial" "$ZONE_FILE" | awk '{print $1}')
if [ ! -z "$OLD_SERIAL" ]; then
    NEW_SERIAL=$((OLD_SERIAL + 1))
    sed -i "s/$OLD_SERIAL/$NEW_SERIAL/g" "$ZONE_FILE"
    echo -e "\e[32m[SUKSES] Serial SOA dinaikkan dari $OLD_SERIAL menjadi $NEW_SERIAL\e[0m"
else
    echo -e "\e[33m[WARNING] Format serial SOA tidak otomatis terdeteksi, silakan naikin manual jika perlu.\e[0m"
fi

echo -e "\nMerefresh/Reload layanan BIND9..."
service bind9 reload

echo -e "\n\e[32m[SELESAI] Konfigurasi DNS beres! Silakan verifikasi dari Alpa.\e[0m"
echo "=========================================================="