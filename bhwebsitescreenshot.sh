#!/bin/bash
GOWITNESS_DOCKER_IMAGE="leonjza/gowitness"
DEFAULT_RESOLUTION_X="1440"
DEFAULT_RESOLUTION_Y="900"
DEFAULT_SCREENSHOT_EXTN="jpg"
DEFAULT_SCREENSHOT_FOLDER="/opt/dockershare/out-vulnreview-webscreenshots"
if [ $# -lt 1 ]; then
    echo "[-] $0 <url> [outfile-name=<default>] [resolution_x=$DEFAULT_RESOLUTION_X] \
[resolution_y=$DEFAULT_RESOLUTION_Y] [screenshot_folder=$DEFAULT_SCREENSHOT_FOLDER] \
[screenshot_extn=$DEFAULT_SCREENSHOT_EXTN]"
    exit 1
fi
url="$1"
outfile_name=${2:-"default"}
resolution_x=${3:-"$DEFAULT_RESOLUTION_X"}
resolution_y=${4:-"$DEFAULT_RESOLUTION_Y"}
screenshot_folder=${5:-"$DEFAULT_SCREENSHOT_FOLDER"}
screenshot_extn=${6:-"$DEFAULT_SCREENSHOT_EXTN"}

echo "[*] Checking if gowitness' docker container image: $GOWITNESS_DOCKER_IMAGE is installed"
does_image_exist=$(docker images | grep -i "$GOWITNESS_DOCKER_IMAGE")

echo "[*] Creating output folder: $screenshot_folder if it doesn't exist"
[ ! -d "$screenshot_folder" ] && mkdir -p "$screenshot_folder"

echo "[*] Installing docker container image: $GOWITNESS_DOCKER_IMAGE"
if [ -z "$does_image_exist" ]; then
    docker pull "$GOWITNESS_DOCKER_IMAGE"
    if [ $? -eq 1 ]; then
        echo "[-] Docker container: $GOWITNESS_DOCKER_IMAGE not available"
        exit 1
    fi
fi
echo "[*] Checking the output file name: $outfile_name"
if [ "$outfile_name" == "default" ]; then
    outfile=$(echo "$url" | tr -s "&=./\:?" "_")
    outfile="$outfile.$screenshot_extn"
else
    outfile="$outfile_name"
fi
outfile_full="$screenshot_folder/$outfile"
echo "[*] screenshot outfile: $outfile, outfile_full: $outfile_full"


echo "[*] Taking the image of url: $url to outfile: $outfile, outfile_full: $outfile_full"
docker run --rm -v "$screenshot_folder":/storage leonjza/gowitness gowitness single -X "$resolution_x" -Y "$resolution_y" -P "/storage" -o "$outfile" "$url"

if [ $? -eq 0 ]; then
    echo "[+] Success. Screenshot for url: $url stored in outfile: $outfile, outfile_full: $outfile_full"
else
    echo "[-] Failure. Screenshot for url: $url not taken. Error should be displayed above."
    exit 1
fi