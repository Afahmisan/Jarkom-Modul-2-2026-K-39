#!/bin/bash

echo "=========================================================="
echo "    VERIFIKASI REVERSE PROXY & FORWARD HEADER THE MESH    "
echo "=========================================================="

# Menggunakan domain www untuk Penny dan static untuk Abbey sesuai zone DNS lu
URL_PENNY="http://www.k-39.com"
URL_ABBEY="http://static.k-39.com"

echo -e "\n[1] MENGUJI GERBANG PENNY (APACHE -> AREA VAULT)"
echo "Ekspektasi: Balasan bergantian antara Obladi & Desmond"
echo "----------------------------------------------------------"
for i in {1..4}; do
    echo -e "\e[33m--- Request #$i ke $URL_PENNY ---\e[0m"
    # Mengambil output curl, membersihkan tag HTML jika ada agar rapi
    curl -s $URL_PENNY | sed -e 's/<[^>]*>//g' | grep -v "^$" | head -n 5
    echo ""
    sleep 1
done

echo -e "\n[2] MENGUJI GERBANG ABBEY (NGINX -> AREA CORE)"
echo "Ekspektasi: Balasan bergantian antara Oblada & Molly"
echo "----------------------------------------------------------"
for i in {1..4}; do
    echo -e "\e[36m--- Request #$i ke $URL_ABBEY ---\e[0m"
    curl -s $URL_ABBEY | sed -e 's/<[^>]*>//g' | grep -v "^$" | head -n 5
    echo ""
    sleep 1
done

echo "=========================================================="