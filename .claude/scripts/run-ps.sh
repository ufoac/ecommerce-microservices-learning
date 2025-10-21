#!/bin/bash
# Wrapper script to run PowerShell scripts properly in Git Bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PS_SCRIPT="$1"

if [ -z "$PS_SCRIPT" ]; then
    echo "Usage: $0 <powershell-script.ps1>"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/$PS_SCRIPT" ]; then
    echo "Error: PowerShell script '$PS_SCRIPT' not found in $SCRIPT_DIR"
    exit 1
fi

# Execute PowerShell script properly
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_DIR/$PS_SCRIPT" "${@:2}"