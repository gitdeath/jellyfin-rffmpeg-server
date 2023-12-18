#!/bin/bash

# Start cron in the background
service cron start

# Start Jellyfin
exec ./jellyfin/jellyfin --datadir /config --cachedir /cache
