#!/bin/bash

# Pastikan apache2-utils terpasang untuk menyediakan binary 'ab'
which ab >/dev/null 2>&1 || {
    apt-get update -y >/dev/null 2>&1
    apt-get install -y apache2-utils >/dev/null 2>&1
}

URL_PENNY="http://www.k-39.com/"
URL_ABBEY="http://static.k-39.com/"
TOTAL_REQ=250
CONCURRENCY=10

echo "=========================================================="
echo "       STRESS TEST BENCHMARK APACHEBENCH (SOAL 16)        "
echo "=========================================================="
echo "Parameter: $TOTAL_REQ Requests | Concurrency: $CONCURRENCY"
echo "----------------------------------------------------------"

echo "[1/2] Menjalankan Benchmark ke Penny ($URL_PENNY)..."
ab -n $TOTAL_REQ -c $CONCURRENCY $URL_PENNY > /tmp/ab_penny.txt 2>&1

echo "[2/2] Menjalankan Benchmark ke Abbey ($URL_ABBEY)..."
ab -n $TOTAL_REQ -c $CONCURRENCY $URL_ABBEY > /tmp/ab_abbey.txt 2>&1

echo -e "\n=========================================================="
echo "            RANGKUMAN HASIL BENCHMARK GERBANG            "
echo "=========================================================="
printf "%-25s | %-15s | %-15s\n" "Metrik Pengujian" "Penny (Apache)" "Abbey (Nginx)"
echo "----------------------------------------------------------"

extract_metric() {
    local file=$1
    local pattern=$2
    grep -E "$pattern" "$file" | head -n1 | awk -F: '{print $2}' | xargs
}

TIME_PENNY=$(extract_metric /tmp/ab_penny.txt "Time taken for tests")
TIME_ABBEY=$(extract_metric /tmp/ab_abbey.txt "Time taken for tests")
printf "%-25s | %-15s | %-15s\n" "Waktu Total" "$TIME_PENNY" "$TIME_ABBEY"

FAIL_PENNY=$(extract_metric /tmp/ab_penny.txt "Failed requests")
FAIL_ABBEY=$(extract_metric /tmp/ab_abbey.txt "Failed requests")
printf "%-25s | %-15s | %-15s\n" "Permintaan Gagal" "${FAIL_PENNY:-0}" "${FAIL_ABBEY:-0}"

RPS_PENNY=$(extract_metric /tmp/ab_penny.txt "Requests per second" | awk '{print $1" [#/sec]"}')
RPS_ABBEY=$(extract_metric /tmp/ab_abbey.txt "Requests per second" | awk '{print $1" [#/sec]"}')
printf "%-25s | %-15s | %-15s\n" "Throughput (RPS)" "$RPS_PENNY" "$RPS_ABBEY"

LAT_PENNY=$(extract_metric /tmp/ab_penny.txt "Time per request:.*mean\)" | awk '{print $1" ms"}')
LAT_ABBEY=$(extract_metric /tmp/ab_abbey.txt "Time per request:.*mean\)" | awk '{print $1" ms"}')
printf "%-25s | %-15s | %-15s\n" "Rata-rata Latensi" "$LAT_PENNY" "$LAT_ABBEY"

RATE_PENNY=$(extract_metric /tmp/ab_penny.txt "Transfer rate" | awk '{print $1" "$2}')
RATE_ABBEY=$(extract_metric /tmp/ab_abbey.txt "Transfer rate" | awk '{print $1" "$2}')
printf "%-25s | %-15s | %-15s\n" "Transfer Rate" "$RATE_PENNY" "$RATE_ABBEY"

echo "=========================================================="