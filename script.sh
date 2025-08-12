#!/bin/bash

# Pastikan .env ada di folder yang sama
set -a
source .env
set +a

# Set current date tanggal mm-dd-yyyy & yyyy-mm-dd hh:mm:ss
tanggal=$(date +"%m-%d-%Y")
waktu=$(date +"%Y-%m-%d %H:%M:%S")

# Pilih lokasi
echo "Kantor:"
echo "1) Mampang Jamsostek"
echo "2) ULTG Bekasi"
echo "3) GUDANG TAMBUN"
read -p "Masukkan nomor kantor: " kantor
##
if [ "$kantor" == "1" ]; then
   # Mampang Jamsostek
   kantorId="AA128"
   latitude="-6.2337616"
   longitude="106.8214132"
elif [ "$kantor" == "2" ]; then
   # ULTG Bekasi
   kantorId="AA370"
   latitude="-6.2046715"
   longitude="106.9834873"
elif [ "$kantor" == "3" ]; then
   # GUDANG TAMBUN
   kantorId="AA408"
   latitude="-6.269886"
   longitude="107.048389"
else
   echo "Kantor tidak valid!"
   exit 1
fi

# List file foto di current dir
echo "File $(pwd):"
files=($(find . -maxdepth 1 -type f -name "*.jpg"))

if [ ${#files[@]} -eq 0 ]; then
   echo "Tidak ada file foto (.jpg) di folder ini."
   exit 1
fi

# Tampilkan daftar
for i in "${!files[@]}"; do
   echo "$((i + 1))) ${files[$i]#./}" # Remove leading "./"
done

# Pilih file
read -p "Masukkan nomor file: " index
if ! [[ "$index" =~ ^[0-9]+$ ]] || [ "$index" -lt 1 ] || [ "$index" -gt ${#files[@]} ]; then
   echo "Nomor file tidak valid!"
   exit 1
fi

FILE="${files[$((index - 1))]}"

if [ ! -f "$FILE" ]; then
  echo "File not found"
  exit 1
fi

# Ambil ukuran file
fileBytes=$(stat -c %s "$FILE" 2>/dev/null || stat -f %z "$FILE")
fileSize=$(( fileBytes / 1000 ))  # Pembulatan ke atas

# Kirim POST request dengan form-data
curl -X POST ${BASE_URL} \
-H "Content-Type:multipart/form-data" \
-H "User-Agent:okhttp/4.9.0" \
-H "Authorization:Bearer ${TOKEN}" \
-F "appVersion=2.0.9" \
-F "deviceType=${DEVICE_TYPE}" \
-F "deviceId=${DEVICE_ID}" \
-F "idPegawai=${ID_PEGAWAI}" \
-F "lvl=AA0303010203" \
-F "organisasi=AA" \
-F "inOut=1" \
-F "wfhWfo=1" \
-F "keterangan=" \
-F "accuracyLocation=13.154" \
-F "latitude=${latitude}" \
-F "longitude=${longitude}" \
-F "statusLocation=2" \
-F "kantorId=${kantorId}" \
-F "zona=7" \
-F "fileSize=${fileSize}" \
-F "height=1080" \
-F "width=810" \
# Remove leading "./" from file path
-F "file=@${files[$((index - 1))]#./}" \
-F "tanggal=${tanggal}" \
-F "waktu=${waktu}"
