#!/bin/bash

python3 -m venv __env__

source __env__/bin/activate

echo "- Bắt đầu cài đặt:"

for dir in lhe_*; do
  if [ -d "$dir" ]; then
    filename=$(basename "$dir" | sed 's/^lhe_//')
    capitalized_filename="$(tr '[:lower:]' '[:upper:]' <<< ${filename:0:1})${filename:1}"

    cd "$dir/web" || continue

    if [ -f requirements.txt ]; then
      pip install -r requirements.txt > /dev/null 2>&1

      echo "  + $capitalized_filename: OK"
    else
      echo "[ERROR] requirements.txt not found in $dir/web"
    fi

    cd - > /dev/null
  fi
done

current_dir=$(pwd)

base_json='{
  "version": "0.2.0",
  "configurations": [],
  "compounds": [
    {
      "name": "Projects LHE Backend",
      "configurations": []
    }
  ]
}'

json=$(echo "$base_json" | jq '.')

i=0

ip_address='127.0.0.1'

if [ "$1" == "--public" ]; then
  ip_address=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
else
  ip_address='127.0.0.1'
fi

for dir in lhe_*; do
  if [ -d "$dir" ]; then
    filename=$(basename "$dir")
    new_filename=$(echo "$filename" | sed 's/^lhe_//')
    capitalized_filename="$(tr '[:lower:]' '[:upper:]' <<< ${new_filename:0:1})${new_filename:1}"

    item=$(
      jq -n --arg i "$i" \
            --arg filename "$filename" \
            --arg ip_address "$ip_address" \
            --arg current_dir "$current_dir" \
            --arg new_filename "$new_filename" \
            --arg capitalized_filename "$capitalized_filename" \
      '{
        "name": "\($capitalized_filename): 800\($i)",
        "type": "debugpy",
        "request": "launch",
        "python": "\($current_dir)/__env__/bin/python3",
        "program": "${workspaceFolder}/\($filename)/web/manage.py",
        "args": ["runserver", "\($ip_address):800\($i)"],
        "consoleTitle": "\($capitalized_filename): 800\($i)",
        "django": true,
        "justMyCode": true
      }'
    )

    json=$(echo "$json" | jq --argjson item "$item" '.configurations += [$item]')

    json=$(echo "$json" | jq --arg capitalized_filename "$capitalized_filename" \
                             --arg i "$i" '.compounds[0].configurations += ["\($capitalized_filename): 800\($i)"]')

    i=$((i + 1))
  fi
done

rm -rf .vscode

mkdir .vscode

echo "$json" > .vscode/launch.json

base_settings_json='{
  "explorer.compactFolders": false
}'

settings_json=$(echo "$base_settings_json" | jq '.')

echo "$settings_json" > .vscode/settings.json

echo "=> Hoàn tất"