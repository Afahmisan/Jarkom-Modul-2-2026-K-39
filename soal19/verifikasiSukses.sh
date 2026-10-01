#!/bin/bash 

dig outbound.k-39.com +short
curl -H "Host: http.badssl.com" http://outbound.k-39.com