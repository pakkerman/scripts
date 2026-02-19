#!/usr/bin/env bash

filepath="$1"
root=$(dirname "$0")
dir=$(dirname "$filepath")
base=$(basename "$filepath")
parsed_filepath="$dir/parsed-$(basename "${filepath%.*}").${filepath##*.}"

data=$(exiftool -UserComment -b "$filepath")

prompt=$(echo "$data" | tr '\n' ' ' | sed 's/Neg.*//')
neg=$(echo "$data" | tr '\n' ' ' | sed 's/^.*Negative prompt: //' | sed 's/Steps.*//')

metadata=$(echo "$data" | tr '\n' ' ' | sed -e 's/.*Steps/Steps/' | sed 's/Created Date:.*, Civitai.*//')
models=$(echo "$data" | tr '\n' ' ' | sed 's/.*Civitai resources: //' | sed 's/, Civitai metadata: {.*}//')
models_json=$(echo "$models" | jq -c -R 'try fromjson')

prompt+=$(node "$root"/civitai-model-parse.js "$models_json")
# echo "$prompt"
output="$prompt 
Negative prompt: $neg 
$metadata"

# echo "$prompt \nNegative prompt: $neg \n$metadata"

exiftool -UserComment="$output" "$filepath"
mv "$filepath" "$parsed_filepath"
mv "$filepath"_original "$filepath"
