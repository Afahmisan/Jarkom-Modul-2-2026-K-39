#!/bin/bash

# Tentukan path file zone lu (sesuaikan jika berbeda)
ZONE_FILE="/etc/bind/k-39/k-39.com"

echo "=========================================================="
echo "    AUTOMATION INJECTION CNAME OUTBOUND (SOAL 19)         "
echo "=========================================================="

if [ ! -f "$ZONE_FILE" ]; then
    echo -e "\e[31mError: File zone $ZONE_FILE tidak ditemukan!\e[0m"
    exit 1
fi

# Cek apakah record outbound sudah ada di dalam file zone
if grep -q "outbound" "$ZONE_FILE"; then
    echo -e "\e[33m[INFO] Record 'outbound' sudah ada di dalam file zone. Melanjutkan reload...\e[0m"
else
    echo -e "\nMenambahkan CNAME outbound ke http.badssl.com..."
    cat << 'EOF' >> "$ZONE_FILE"

; --- Otomasi CNAME Outbound Eksternal (Soal 19) ---
outbound    IN  CNAME   http.badssl.com.
EOF
    echo -e "\e[32m[SUKSES] Baris CNAME outbound berhasil disuntikkan.\e[0m"
fi

# Menaikkan serial SOA secara otomatis agar slave dan cache langsung update
OLD_SERIAL=$(grep -E "[0-9]{10}\s+;\s*Serial" "$ZONE_FILE" | awk '{print $1}')
if [ ! -z "$OLD_SERIAL" ]; then
    NEW_SERIAL=$((OLD_SERIAL + 1))
    sed -i "s/$OLD_SERIAL/$NEW_SERIAL/g" "$ZONE_FILE"
    echo -e "\e[32m[SUKSES] Serial SOA dinaikkan dari $OLD_SERIAL menjadi $NEW_SERIAL\e[0m"
else
    echo -e "\e[33m[WARNING] Format serial SOA tidak terdeteksi otomatis.\e[0m"
fi

echo -e "\nMerefresh/Reload layanan BIND9 di Prab..."
service bind9 reload

echo -e "\n\e[32m[SELESAI] Konfigurasi Soal 19 siap didemokan!\e[0m"
echo "=========================================================="