#!/bin/bash

for dir in lhe_*; do
  if [ -d "$dir" ]; then
    filename=$(basename "$dir" | sed 's/^lhe_//')
    capitalized_filename="$(tr '[:lower:]' '[:upper:]' <<< ${filename:0:1})${filename:1}"

    cd "$dir/web" || continue

    function find_wsgi_dir {
      local _wsgi_file=$(find . -type f -name "wsgi.py" | head -n 1)
      if [ -z "$_wsgi_file" ]; then
          echo "WSGI configuration file 'wsgi.py' not found."
          exit 1
      fi
      local wsgi_dir=$(dirname "$_wsgi_file")
      echo "$wsgi_dir/wsgi.py"
    }

    wsgi_file=$(find_wsgi_dir)

    if [ ! -f "$wsgi_file" ]; then
        echo "WSGI configuration file '$wsgi_file' not found."
        exit 1
    fi

    if [ "$1" == '-o' ]; then
      sed -i '' -e 's/^# \( *import tracing[[:space:]]*$\)/\1/' "$wsgi_file"
      sed -i '' -e 's/^# \( *from opentelemetry.instrumentation.wsgi import OpenTelemetryMiddleware\)/\1/' "$wsgi_file"
      sed -i '' -e 's/^# \( *application = OpenTelemetryMiddleware(application)\)/\1/' "$wsgi_file"
    else
      sed -i '' -e 's/^\( *import tracing\)/# \1/' "$wsgi_file"
      sed -i '' -e 's/^\( *from opentelemetry.instrumentation.wsgi import OpenTelemetryMiddleware\)/# \1/' "$wsgi_file"
      sed -i '' -e 's/^\( *application = OpenTelemetryMiddleware(application)\)/# \1/' "$wsgi_file"
    fi

    cd - > /dev/null
  fi
done