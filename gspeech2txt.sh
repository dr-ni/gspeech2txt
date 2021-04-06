#!/bin/bash
#
# curl google speech api example
# UN 05.04.2021
#
# dependencies
# sudo apt-get install curl
# sudo apt-get install sox
# sudo apt-get install coreutils

SAMPLE_RATE=16000
# create api-key at https://console.cloud.google.com/apis/credentials
KEY="......your-api-key......."

START="transcript\": \""
END="\","


rec -c1 file.flac vad -s 1 -t 7 -T 0.2 -g 0.5 silence -l 0 0 0:00:03 1% rate $SAMPLE_RATE
#play -c1 file.flac 
base64 file.flac -w 0 > file.flac.base64
base64_flac=$(cat file.flac.base64)
echo '{"audio":{"content": "'$base64_flac'"}, "config":{"encoding":"FLAC","audio_channel_count":"1","sample_rate_hertz":"'$SAMPLE_RATE'","language_code":"de-DE"}}' > body.txt
curl -o stt.txt -X POST -H "Content-Type: application/json" -d @body.txt "https://speech.googleapis.com/v1/speech:recognize?key=$KEY" >/dev/null 2>&1 | sed -e 's/[{}]/''/g' | awk -F\":\" '{print $4}' | awk -F\",\" '{print $1}' | tr -d '\\n' >/dev/null 2>&1

echo
more stt.txt | grep -o "$START\(.*\)$END" | awk -F "$START" '{ print $2 }' | sed 's/'$END'/''/g'
more stt.txt | grep -o "$START\(.*\)$END" | awk -F "$START" '{ print $2 }' | sed 's/'$END'/''/g' | tr -d '\n' > erg.txt

