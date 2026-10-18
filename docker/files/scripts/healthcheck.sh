#!/bin/bash
# Set shell options
set -euo pipefail

# Port of the filter
PORT="${PORT:-2375}"

# Open TCP connection to the filter
exec 3<>"/dev/tcp/127.0.0.1/${PORT}"

# Send ping request
printf 'GET /_ping HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n' >&3

# Read status line -> "HTTP/1.1 200 OK"
read -r -t 5 status_line <&3
status_line="${status_line%$'\r'}"

# Close connection
exec 3>&-

# Healthy only on HTTP 200
if [[ "${status_line}" =~ ^HTTP/1\.[01]\ 200 ]]
then
    exit 0
else
    echo "Unhealthy: ${status_line:-No response}"
    exit 1
fi