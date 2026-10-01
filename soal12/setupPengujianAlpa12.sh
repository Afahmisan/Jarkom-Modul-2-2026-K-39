#!/bin/bash

# Warna output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}       PENGUJIAN SISTEM JARINGAN THE MESH           ${NC}"
echo -e "${BLUE}====================================================${NC}\n"

# 1. UJI RESOLUSI DNS
echo -e "${BLUE}[1/6] Uji Resolusi Domain & Subdomain...${NC}"
for domain in k-39.com penny.k-39.com abbey.k-39.com; do
    if ping -c 1 -W 1 $domain >/dev/null 2>&1; then
        echo -e "  [DNS] $domain -> ${GREEN}RESOLVED (OK)${NC}"
    else
        echo -e "  [DNS] $domain -> ${RED}FAILED${NC}"
    fi
done

# 2. UJI DISTRIBUSI BEBAN PENNY -> AREA VAULT (OBLADI & DESMOND)
echo -e "\n${BLUE}[2/6] Uji Load Balancing Penny -> Vault (Obladi & Desmond)...${NC}"
echo "Mengirim 4 request ke http://penny.k-39.com/ :"
for i in {1..4}; do
    RESP=$(curl -s http://penny.k-39.com/ | grep -iE "obladi|desmond" | sed -e 's/<[^>]*>//g' | tr -d '\n\r' | xargs)
    if [ -n "$RESP" ]; then
        echo -e "  Request $i: ${GREEN}$RESP${NC}"
    else
        echo -e "  Request $i: ${RED}Gagal mendapatkan respons node${NC}"
    fi
done

# 3. UJI DISTRIBUSI BEBAN ABBEY -> AREA CORE (OBLADA & MOLLY)
echo -e "\n${BLUE}[3/6] Uji Load Balancing Abbey -> Core (Oblada & Molly)...${NC}"
echo "Mengirim 4 request ke http://abbey.k-39.com/ :"
for i in {1..4}; do
    RESP=$(curl -s http://abbey.k-39.com/ | grep -iE "oblada|molly" | sed -e 's/<[^>]*>//g' | tr -d '\n\r' | xargs)
    if [ -n "$RESP" ]; then
        echo -e "  Request $i: ${GREEN}$RESP${NC}"
    else
        echo -e "  Request $i: ${RED}Gagal mendapatkan respons node${NC}"
    fi
done

# 4. UJI JALUR LAYANAN MANDIRI (/eternal & /orion)
echo -e "\n${BLUE}[4/6] Uji Jalur Layanan Mandiri (/eternal & /orion)...${NC}"
ETERNAL_TEST=$(curl -s http://penny.k-39.com/eternal/ | grep -i "php rendering" || true)
if [ -n "$ETERNAL_TEST" ]; then
    echo -e "  Penny /eternal/ : ${GREEN}OK (PHP berhasil dieksekusi)${NC}"
else
    echo -e "  Penny /eternal/ : ${RED}GAGAL (PHP tidak ter-render)${NC}"
fi

ORION_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://abbey.k-39.com/orion/)
if [ "$ORION_STATUS" -eq 200 ]; then
    echo -e "  Abbey /orion/   : ${GREEN}OK (Statis 200 OK)${NC}"
else
    echo -e "  Abbey /orion/   : ${RED}GAGAL (Status HTTP: $ORION_STATUS)${NC}"
fi

# 5. UJI FITUR TAMBAHAN (Autoindex /arsip/ & Clean URL /profil)
echo -e "\n${BLUE}[5/6] Uji Autoindex Arsip & Clean URL Profil...${NC}"
ARSIP_TEST=$(curl -s http://penny.k-39.com/arsip/ | grep -i "Index of" || true)
if [ -n "$ARSIP_TEST" ]; then
    echo -e "  Autoindex /arsip/ : ${GREEN}OK (Directory Listing Aktif)${NC}"
else
    echo -e "  Autoindex /arsip/ : ${RED}GAGAL / Kurang Tepat${NC}"
fi

PROFIL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://abbey.k-39.com/profil)
if [ "$PROFIL_STATUS" -eq 200 ]; then
    echo -e "  Clean URL /profil : ${GREEN}OK (Rewrite Berhasil - 200 OK)${NC}"
else
    echo -e "  Clean URL /profil : ${RED}GAGAL (Status HTTP: $PROFIL_STATUS)${NC}"
fi

# 6. UJI PROTEKSI DOKUMEN RAHASIA SINDIKAT (/admin - BASIC AUTH)
echo -e "\n${BLUE}[6/6] Uji Basic Authentication Dokumen Rahasia (/admin)...${NC}"

# A. Tanpa Kredensial -> Harus 401 Unauthorized
CODE_NO_AUTH=$(curl -s -o /dev/null -w "%{http_code}" http://penny.k-39.com/admin/)
if [ "$CODE_NO_AUTH" -eq 401 ]; then
    echo -e "  Akses tanpa kredensial   : ${GREEN}DITOLAK (401 Unauthorized - OK)${NC}"
else
    echo -e "  Akses tanpa kredensial   : ${RED}GAGAL (Status HTTP: $CODE_NO_AUTH, Harusnya 401)${NC}"
fi

# B. Kredensial Salah -> Harus 401 Unauthorized
CODE_WRONG_AUTH=$(curl -s -o /dev/null -w "%{http_code}" -u prabs:passwordsalah http://penny.k-39.com/admin/)
if [ "$CODE_WRONG_AUTH" -eq 401 ]; then
    echo -e "  Akses kredensial salah   : ${GREEN}DITOLAK (401 Unauthorized - OK)${NC}"
else
    echo -e "  Akses kredensial salah   : ${RED}GAGAL (Status HTTP: $CODE_WRONG_AUTH, Harusnya 401)${NC}"
fi

# C. Kredensial Benar -> Harus 200 OK dan Konten Terbaca
RESP_CORRECT_AUTH=$(curl -s -u prabs:'pakar_pinter_jadi_gob***' http://penny.k-39.com/admin/)
CODE_CORRECT_AUTH=$(curl -s -o /dev/null -w "%{http_code}" -u prabs:'pakar_pinter_jadi_gob***' http://penny.k-39.com/admin/)

if [ "$CODE_CORRECT_AUTH" -eq 200 ] && echo "$RESP_CORRECT_AUTH" | grep -qi "Dokumen Rahasia Sindikat"; then
    echo -e "  Akses kredensial benar   : ${GREEN}DIIZINKAN (200 OK & Dokumen Rahasia Terbuka)${NC}"
else
    echo -e "  Akses kredensial benar   : ${RED}GAGAL (Status HTTP: $CODE_CORRECT_AUTH)${NC}"
fi

echo -e "\n${BLUE}====================================================${NC}"
echo -e "${BLUE}                 PENGUJIAN SELESAI                  ${NC}"
echo -e "${BLUE}====================================================${NC}"