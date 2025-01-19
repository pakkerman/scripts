#!/bin/bash

filepath="$1"
dir=$(dirname "$filepath")
base=$(basename "$filepath")
parsed_filepath="$dir/parsed-$(basename "${filepath%.*}").${filepath##*.}"

data=$(exiftool -UserComment -b "$filepath")

prompt=$(echo $data | sed 's/ Neg.*//')
neg=$(echo $data | sed 's/^.*Negative prompt: //' | sed 's/Steps.*//')
metadata=$(echo $data | sed -e 's/.*Steps/Steps/' | sed 's/Created Date:.*, Civitai.*//')
models=$(echo $data | sed 's/.*Civitai resources: //' | sed 's/, Civitai metadata: {}//')
models_json=$(echo $models | jq -c .)

prompt+=$(node ./civitai-model-parse.js "$models_json")
echo "$prompt"
output="$prompt 
Negative prompt: $neg 
$metadata"

# echo "$prompt \nNegative prompt: $neg \n$metadata"

exiftool -UserComment="$output" "$filepath"
mv "$filepath" "$parsed_filepath"
mv "$filepath"_original "$filepath"
