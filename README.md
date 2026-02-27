# Omega Recon 🎯

A powerful bug bounty reconnaissance and vulnerability discovery suite. `omega-recon` automates the boring parts of recon, from subdomain enumeration to targeted vulnerability scanning.

## 🚀 Features

- **Subdomain Enumeration**: Multi-tool discovery using `subfinder`, `assetfinder`, and `findomain`.
- **Live Host Detection**: Identifies alive subdomains and categorizes them by status codes (200, 403, 404).
- **URL Harvesting**: Deep crawling and historical URL collection using `katana`, `gau`, `hakrawler`, and `urlfinder`.
- **Pattern Matching**: Automatic filtering of interesting parameters and endpoints using `gf` patterns.
- **XSS Scanning**: Targeted XSS vulnerability detection using `dalfox`.
- **Organized Output**: Creates structured directories for each target domain.

## 🛠️ Prerequisites

The scripts are optimized for:

- **Kali Linux**
- **Arch Linux**
- **Go** (Golang) environment

## 📥 Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/0xInjustice/omega-recon.git
   cd omega-recon
   ```

2. **Run the installer**:
   The `install.sh` script will detect your OS and install all required system packages and Go-based tools.

   ```bash
   chmod +x install.sh
   ./install.sh
   ```

## 🔍 Usage

### 1. Main Recon Workflow

Start the full reconnaissance process for a target domain:

```bash
chmod +x omega-recon.sh
./omega-recon.sh
```

Enter the target domain (e.g., `example.com`) when prompted. The script will:

- Discover subdomains.
- Filter live hosts.
- Collect and deduplicate URLs.
- Run `gf` patterns on collected URLs.

### 2. XSS Scanning

Once the main recon is complete, run the XSS scanner:

```bash
chmod +x xss.sh
./xss.sh
```

This script looks for `gf/gf_xss.txt` or `xss.txt` in the current directory and runs `dalfox` against found parameters.

## 📁 Directory Structure

```text
target.com/
├── subdomains/           # Alive, 403, and 404 subdomains
├── urls/                 # All discovered URLs and filtered endpoints
├── gf/                   # Categorized URLs (XSS, SQLi, SSRF, etc.)
└── scans/                # Vulnerability scan results
```

## ⚠️ Disclaimer

This tool is created for **educational purposes** and **authorized security testing** only. The author is not responsible for any misuse or damage caused by this tool. Always obtain explicit permission from the target organization before performing any security assessment.

---

Maintained by [0xinjustice](https://github.com/0xinjustice)
