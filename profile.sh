#!/bin/bash

# Pastikan .env ada di folder yang sama
set -a
source .env
set +a

json=$(cat <<EOF
{
  "organisasi": "AA",
  "pegawaiId": "$ID_PEGAWAI"
}
EOF
)

# echo "$TOKEN"
# echo "$json"
# Kirim POST request dengan form-data
curl -X POST https://essplus.iconpln.co.id/essplus-mobile/pegawai/lihat/detail  \
-H "Content-Type:application/json" \
-H "User-Agent:okhttp/4.9.0" \
-H "Authorization:Bearer $TOKEN" \
-d "$json"
