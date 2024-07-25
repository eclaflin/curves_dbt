#!/bin/sh

apt-get update && apt-get install -y git
pip install -r requirements.txt
exec "$@"  # This allows overriding the command when running the container
tail -f /dev/null  # Keep the container running

