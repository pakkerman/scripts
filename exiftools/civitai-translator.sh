#/bin/bash

filepath=$1
dir=$(dirname $filepath)
base=$(basename $filepath)
parsed_filepath="$dir/$(basename "parsed-${filepath%.*}").${filepath##*.}"

data=$(exiftool -UserComment -b "$filepath")

prompt=$(echo $data | sed 's/ Neg.*//')
neg=$(echo $data | sed 's/^.*Negative prompt: //' | sed 's/Steps.*//')
metadata=$(echo $data | sed -e 's/.*Steps/Steps/' | sed 's/Created Date:.*, Civitai.*//')
models=$(echo $data | sed 's/.*Civitai resources: //' | sed 's/, Civitai metadata: {}//')
models_json=$(echo $models | jq -c .)

prompt+=$(echo $(node ./civitai-model-parse.js "$models_json"))
output=$(echo "$prompt \nNegative prompt: $neg \n$metadata")

# echo "$prompt \nNegative prompt: $neg \n$metadata"

cp "$filepath" "$parsed_filepath"

exiftool -UserComment="$output" "$parsed_filepath"
