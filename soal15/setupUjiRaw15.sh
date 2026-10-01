#!/bin/bash

echo "=========================================================="
echo "          PENGUJIAN VALIDASI JALUR MANDIRI (SOAL 15)      "
echo "=========================================================="

echo -e "\n--- 1. UJI PENNY: /eternal/ (Reverse Proxy FastCGI & PHP Rendering) ---"
curl -i http://www.k-39.com/eternal/

echo -e "\n--- Bukti Eksekusi Dinamis (Detik server wajib bertambah) ---"
echo -n "Request 1: "
curl -s http://www.k-39.com/eternal/ | grep -o "Waktu Server:.*" || true
sleep 2
echo -n "Request 2: "
curl -s http://www.k-39.com/eternal/ | grep -o "Waktu Server:.*" || true

echo -e "\n----------------------------------------------------------"
echo -e "--- 2. UJI ABBEY: /orion/ (Penyajian Statis Normal) ---"
curl -i http://static.k-39.com/orion/

echo -e "\n----------------------------------------------------------"
echo -e "--- 3. UJI ABBEY: /orion/tes.php (BUKTI PHP TIDAK DIRENDER) ---"
echo "Ekspektasi: Kode PHP harus keluar sebagai TEKS MENTAH, bukan dieksekusi!"
curl -i http://static.k-39.com/orion/tes.php

echo -e "\n=========================================================="
echo "               PENGUJIAN ALPA SELESAI                     "
echo "=========================================================="