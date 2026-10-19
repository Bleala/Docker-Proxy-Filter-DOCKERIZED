#!/bin/sh
# Set shell options
set -eu

# Port of the filter
PORT="${PORT:-2375}"

# Healthy only on HTTP 2xx (wget exits non-zero otherwise)
if wget -q -O /dev/null -T 5 "http://127.0.0.1:${PORT}/_ping"
then
    exit 0
else
    echo "Unhealthy: /_ping on port ${PORT} failed."
    exit 1
fi