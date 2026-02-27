#!/usr/bin/env bash
set -euo pipefail

# Runs dalfox against gf-generated xss.txt
# Expects: gf/xss.txt or ./xss.txt

#######################################
# Ensure dalfox installed
#######################################
ensure_dalfox() {
    if ! command -v dalfox >/dev/null 2>&1; then
        echo "Dalfox not found. Please run ./install.sh first."
        exit 1
    fi
}

#######################################
# Locate xss.txt
#######################################
locate_input() {
    if [[ -f "gf/gf_xss.txt" ]]; then
        INPUT="gf/gf_xss.txt"
    elif [[ -f "xss.txt" ]]; then
        INPUT="xss.txt"
    else
        echo "xss.txt not found."
        exit 1
    fi
}

#######################################
# Run Dalfox
#######################################
run_dalfox() {
    mkdir -p scans

    dalfox file "$INPUT" \
        --silence \
        --skip-bav \
        --skip-mining-dom \
        --only-poc r \
        --output scans/dalfox_xss.txt
}

#######################################
# Execution
#######################################
ensure_dalfox
locate_input
run_dalfox

echo "Dalfox scan completed."
