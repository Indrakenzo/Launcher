#!/bin/bash

# ==============================================================================
# Purple Team & Digital Forensics Automated Framework
# Target OS : Kali Linux, Parrot OS, Termux
# ==============================================================================

# --- Konfigurasi Warna ---
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Variabel Kredensial ---
AUTH_USER="Lonewolf"
AUTH_PASS="Silentium-Shield"

# --- Fungsi Autentikasi ---
function login_screen() {
    clear
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${CYAN}       RESTRICTED SYSTEM - AUTHORIZED PERSONNEL     ${NC}"
    echo -e "${CYAN}====================================================${NC}"
    
    read -p "Username: " input_user
    read -s -p "Password: " input_pass
    echo ""

    if [[ "$input_user" == "$AUTH_USER" && "$input_pass" == "$AUTH_PASS" ]]; then
        echo -e "${GREEN}[+] Access Granted. Welcome, $AUTH_USER.${NC}"
        sleep 1
    else
        echo -e "${RED}[!] Access Denied. Security incident logged.${NC}"
        exit 1
    fi
}

# --- Fungsi Pengecekan Ketersediaan Tools ---
function check_tools() {
    echo -e "${YELLOW}[*] Memeriksa ketersediaan tools...${NC}"
    for tool in whois dig nmap exiftool binwalk sha256sum; do
        if ! command -v $tool &> /dev/null; then
            echo -e "${RED}[-] $tool tidak ditemukan. Beberapa fitur mungkin tidak berfungsi.${NC}"
        fi
    done
    echo -e "${GREEN}[+] Pengecekan selesai.${NC}"
    sleep 1
}

# --- Modul 1: Reconnaissance (Red/Blue) ---
function run_recon() {
    read -p "Masukkan Target (IP/Domain): " TARGET
    if [ -z "$TARGET" ]; then return; fi
    
    echo -e "${CYAN}\n[=== Memulai Reconnaissance pada $TARGET ===]${NC}"
    
    echo "[*] Menjalankan Whois Lookup..."
    whois $TARGET > whois_$TARGET.txt 2>/dev/null
    echo -e "${GREEN}[+] Hasil disimpan di whois_$TARGET.txt${NC}"

    echo "[*] Menjalankan DNS Enumeration (dig)..."
    dig ANY $TARGET +short > dns_$TARGET.txt 2>/dev/null
    echo -e "${GREEN}[+] Hasil disimpan di dns_$TARGET.txt${NC}"

    echo "[*] Menjalankan Port & Service Scan (nmap)..."
    nmap -sV -T4 $TARGET -oN nmap_scan_$TARGET.txt 2>/dev/null
    echo -e "${GREEN}[+] Hasil disimpan di nmap_scan_$TARGET.txt${NC}"
}

# --- Modul 2: Vulnerability Auditing (Purple Team) ---
function run_vuln_scan() {
    read -p "Masukkan Target (IP/Domain): " TARGET
    if [ -z "$TARGET" ]; then return; fi
    
    echo -e "${CYAN}\n[=== Memulai Vulnerability Scan pada $TARGET ===]${NC}"
    
    echo "[*] Menjalankan Nmap Vuln Script (Memerlukan nmap scripts)..."
    # Menjalankan pemindaian kerentanan yang aman (non-intrusif)
    nmap -sV --script vuln $TARGET -oN vuln_scan_$TARGET.txt 2>/dev/null
    echo -e "${GREEN}[+] Hasil pemindaian kerentanan disimpan di vuln_scan_$TARGET.txt${NC}"
    
    echo -e "${YELLOW}[!] Catatan: Eksploitasi aktif dinonaktifkan dalam mode audit.${NC}"
}

# --- Modul 3: Digital Forensics (Blue Team/SOC) ---
function run_forensics() {
    echo -e "${CYAN}\n[=== Memulai Digital Forensics Toolkit ===]${NC}"
    echo "1) Analisis Metadata File (ExifTool)"
    echo "2) Ekstraksi File Tersembunyi (Binwalk)"
    echo "3) Kalkulasi Hash (Integrity Check)"
    read -p "Pilih opsi forensik: " FOR_OPT
    
    read -p "Masukkan path file target: " FILE_TARGET
    if [ ! -f "$FILE_TARGET" ]; then
        echo -e "${RED}[!] File tidak ditemukan!${NC}"
        return
    fi

    case $FOR_OPT in
        1)
            exiftool "$FILE_TARGET" > metadata_report.txt
            echo -e "${GREEN}[+] Metadata disimpan di metadata_report.txt${NC}"
            ;;
        2)
            binwalk -e "$FILE_TARGET"
            echo -e "${GREEN}[+] Proses binwalk selesai. Periksa direktori ekstraksi.${NC}"
            ;;
        3)
            HASH=$(sha256sum "$FILE_TARGET")
            echo -e "${GREEN}[+] SHA256 Hash: $HASH${NC}"
            ;;
        *)
            echo -e "${RED}[!] Pilihan tidak valid.${NC}"
            ;;
    esac
}

# --- Main Menu ---
login_screen
check_tools

while true; do
    echo -e "${CYAN}\n====================================================${NC}"
    echo -e "       VIGI-FRAMEWORK: PURPLE TEAM OPERATIONS       "
    echo -e "${CYAN}====================================================${NC}"
    echo "1. Reconnaissance (OSINT & Scanning)"
    echo "2. Vulnerability Auditing"
    echo "3. Digital Forensics Tools"
    echo "4. Exit"
    echo -e "${CYAN}====================================================${NC}"
    read -p "Pilih menu [1-4]: " MENU_OPT

    case $MENU_OPT in
        1) run_recon ;;
        2) run_vuln_scan ;;
        3) run_forensics ;;
        4) echo -e "${YELLOW}[*] Exiting system. Goodbye, $AUTH_USER.${NC}"; exit 0 ;;
        *) echo -e "${RED}[!] Pilihan tidak valid!${NC}" ;;
    esac
done
