#!/bin/bash
mkdir -p ~/Pictures/Screenshots/Regional
FILENAME=~/Pictures/Screenshots/Regional/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png
grim -g "$(slurp)" "$FILENAME"
