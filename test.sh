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
read -p "Masukkan nomor kantor: " kantor

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
photo="${files[$((index - 1))]#./}" # Remove leading "./"

if [ ! -f "$FILE" ]; then
  echo "File not found"
  exit 1
fi

# Ambil ukuran file
fileBytes=$(stat -c %s "$FILE" 2>/dev/null || stat -f %z "$FILE")
fileSize=$(( fileBytes / 1000 ))  # Pembulatan ke atas

# Output
echo "POST ${BASE_URL}"
echo "Content-Type:multipart/form-data"
echo "User-Agent:okhttp/4.9.0"
echo "Authorization:Bearer ${TOKEN}"
echo "appVersion=2.0.9"
echo "deviceType=${DEVICE_TYPE}"
echo "deviceId=${DEVICE_ID}"
echo "idPegawai=${ID_PEGAWAI}"
echo "lvl=AA0303010205"
echo "organisasi=AA"
echo "inOut=1"
echo "wfhWfo=1"
echo "keterangan="
echo "accuracyLocation=13.154"
echo "latitude=${latitude}"
echo "longitude=${longitude}"
echo "statusLocation=2"
echo "kantorId=${kantorId}"
echo "zona=7"
echo "fileSize=${fileSize}"
echo "height=1080"
echo "width=810" 
echo "file=@${photo}"
echo "tanggal=${tanggal}"
echo "waktu=${waktu}"
echo "https://www.google.com/maps?q=${latitude},${longitude}"
