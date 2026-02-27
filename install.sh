#!/usr/bin/env bash
set -euo pipefail

#######################################
# Detect OS (Arch or Kali)
#######################################
detect_os() {
    if [[ -f /etc/arch-release ]]; then
        OS="arch"
    elif grep -qi kali /etc/os-release 2>/dev/null; then
        OS="kali"
    else
        echo "Unsupported OS. Only Arch and Kali supported."
        exit 1
    fi
}

#######################################
# Install system package
#######################################
install_pkg() {
    pkg="$1"

    if [[ "$OS" == "arch" ]]; then
        sudo pacman -Sy --noconfirm "$pkg"
    elif [[ "$OS" == "kali" ]]; then
        sudo apt update -y
        sudo apt install -y "$pkg"
    fi
}

#######################################
# Ensure Go installed
#######################################
ensure_go() {
    if ! command -v go >/dev/null 2>&1; then
        install_pkg go
    fi

    export PATH="$PATH:$(go env GOPATH)/bin"
}

#######################################
# Ensure Go tool installed
#######################################
ensure_go_tool() {
    tool_bin="$1"
    go_pkg="$2"

    if ! command -v "$tool_bin" >/dev/null 2>&1; then
        GO111MODULE=on go install "$go_pkg@latest"
    fi
}

#######################################
# Ensure System tool installed
#######################################
ensure_tool() {
    tool="$1"
    pkg_arch="$2"
    pkg_kali="$3"

    if ! command -v "$tool" >/dev/null 2>&1; then
        if [[ "$OS" == "arch" ]]; then
            install_pkg "$pkg_arch"
        else
            install_pkg "$pkg_kali"
        fi
    fi
}

gf_ensure() {
    # ensure gf binary
    if ! command -v gf >/dev/null 2>&1; then
        GO111MODULE=on go install github.com/tomnomnom/gf@latest || return 1
        export PATH="$PATH:$(go env GOPATH)/bin"
    fi

    local gf_dir="${GF_PATH:-$HOME/.gf}"
    mkdir -p "$gf_dir"

    local tmp1 tmp2

    # load official examples
    tmp1="$(mktemp -d)" || return 1
    git clone --depth 1 https://github.com/tomnomnom/gf.git "$tmp1" || { rm -rf "$tmp1"; return 1; }

    # load 1ndianl33t patterns
    tmp2="$(mktemp -d)" || { rm -rf "$tmp1"; return 1; }
    git clone --depth 1 https://github.com/1ndianl33t/Gf-Patterns.git "$tmp2" || { rm -rf "$tmp1" "$tmp2"; return 1; }

    # copy official patterns first
    cp "$tmp1"/examples/*.json "$gf_dir"/ 2>/dev/null

    # copy Indianl33t patterns, overwrite only if not existing
    for f in "$tmp2"/*.json; do
        name="$(basename "$f")"
        if [ ! -f "$gf_dir/$name" ]; then
            cp "$f" "$gf_dir/"
        fi
    done

    rm -rf "$tmp1" "$tmp2"
}
#######################################
# Start
#######################################
detect_os
ensure_go
gf_ensure
# Core tools
ensure_tool dig bind kali-linux-large
ensure_tool nmap nmap nmap
ensure_tool git git git

# Go-based tools
ensure_go_tool subfinder github.com/projectdiscovery/subfinder/v2/cmd/subfinder
ensure_go_tool httpx github.com/projectdiscovery/httpx/cmd/httpx
ensure_go_tool nuclei github.com/projectdiscovery/nuclei/v3/cmd/nuclei
ensure_go_tool katana github.com/projectdiscovery/katana/cmd/katana
ensure_go_tool assetfinder github.com/tomnomnom/assetfinder
ensure_go_tool gau github.com/lc/gau/v2/cmd/gau
ensure_go_tool gf github.com/tomnomnom/gf
ensure_go_tool hakrawler github.com/hakluke/hakrawler
ensure_go_tool urldedupe github.com/ameenmaali/urldedupe
ensure_go_tool urlfinder github.com/projectdiscovery/urlfinder/cmd/urlfinder
ensure_go_tool findomain github.com/findomain/findomain
ensure_go_tool dalfox github.com/hahwul/dalfox/v2@latest
            export PATH="$PATH:$(go env GOPATH)/bin"

echo "All required tools verified or installed."
