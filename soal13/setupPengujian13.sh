#!/bin/bash

IP_PENNY="10.83.3.2"
IP_ABBEY="10.83.2.2"

# Pastikan domain kanonik bisa di-resolve lokal di Alpa jika DNS belum terdaftar
grep -qxF "$IP_PENNY www.k-39.com" /etc/hosts || echo "$IP_PENNY www.k-39.com" >> /etc/hosts
grep -qxF "$IP_ABBEY static.k-39.com" /etc/hosts || echo "$IP_ABBEY static.k-39.com" >> /etc/hosts

echo "=========================================================="
echo " 1. UJI REDIRECT PERMANEN PENNY (301 -> www.k-39.com)"
echo "=========================================================="
echo "--- A. Akses Domain penny.k-39.com ---"
curl -I http://penny.k-39.com/

echo -e "\n--- B. Akses Langsung IP Penny ($IP_PENNY) ---"
curl -I http://$IP_PENNY/


echo -e "\n=========================================================="
echo " 2. UJI REDIRECT SEMENTARA ABBEY (302 -> static.k-39.com)"
echo "=========================================================="
echo "--- A. Akses Domain abbey.k-39.com ---"
curl -I http://abbey.k-39.com/

echo -e "\n--- B. Akses Langsung IP Abbey ($IP_ABBEY) ---"
curl -I http://$IP_ABBEY/


echo -e "\n=========================================================="
echo " 3. UJI LOAD BALANCING VIA NAMA KANONIK"
echo "=========================================================="
echo "--- Penny: 4x Request ke http://www.k-39.com/ (Vault) ---"
for i in {1..4}; do
    echo ">> Request $i:"
    curl -s http://www.k-39.com/ | grep -iE "obladi|desmond" | sed -e 's/<[^>]*>//g' | xargs
done

echo -e "\n--- Abbey: 4x Request ke http://static.k-39.com/ (Core) ---"
for i in {1..4}; do
    echo ">> Request $i:"
    curl -s http://static.k-39.com/ | grep -iE "oblada|molly" | sed -e 's/<[^>]*>//g' | xargs
done


echo -e "\n=========================================================="
echo " 4. UJI JALUR MANDIRI & FITUR BACKEND"
echo "=========================================================="
echo "--- FastCGI PHP Lokal Penny (http://www.k-39.com/eternal/) ---"
curl -i http://www.k-39.com/eternal/

echo -e "\n--- Statis Lokal Abbey (http://static.k-39.com/orion/) ---"
curl -i http://static.k-39.com/orion/

echo -e "\n--- Autoindex Vault (http://www.k-39.com/arsip/) ---"
curl -I http://www.k-39.com/arsip/

echo -e "\n--- Clean URL Core (http://static.k-39.com/profil) ---"
curl -I http://static.k-39.com/profil


echo -e "\n=========================================================="
echo " 5. UJI BASIC AUTH DOKUMEN RAHASIA (/admin)"
echo "=========================================================="
echo "--- A. Tanpa Kredensial (Harus 401) ---"
curl -I http://www.k-39.com/admin/

echo -e "\n--- B. Kredensial Benar (Harus 200 OK & Konten Terbaca) ---"
curl -i -u prabs:'pakar_pinter_jadi_gob***' http://www.k-39.com/admin/

echo -e "\n=========================================================="
echo "                 PENGUJIAN RAW SELESAI                    "
echo "=========================================================="