#!/bin/sh
#
# Installer script ZTE MF90 Modem Rebooter untuk OpenWrt
# Created by JotaroTol

# --- Konfigurasi ---
REBOOT_SCRIPT_NAME="reboot.py"
REBOOT_SCRIPT_PATH="/usr/bin/$REBOOT_SCRIPT_NAME" 
REQUIREMENTS_FILE="requirements.txt"
REQUIREMENTS_PATH="/tmp/$REQUIREMENTS_FILE" 
PYTHON_CMD="python3" 
PIP_CMD="pip3"     


command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_python_pip() {
    echo "Memeriksa instalasi Python dan pip..."
    if ! command_exists "$PYTHON_CMD"; then
        echo "Python3 tidak ditemukan. Mencoba menginstal..."
        opkg update || { echo "Gagal update opkg. Cek koneksi internet."; exit 1; }
        opkg install python3 || { echo "Gagal menginstal Python3. Pastikan repositori OpenWrt dikonfigurasi dengan benar."; exit 1; }
        if ! command_exists "$PYTHON_CMD"; then
            echo "Gagal menginstal Python3. Silakan instal secara manual: opkg update && opkg install python3"
            exit 1
        fi
    fi

    if ! command_exists "$PIP_CMD"; then
        echo "pip3 tidak ditemukan. Mencoba menginstal..."
        opkg update || { echo "Gagal update opkg. Cek koneksi internet."; exit 1; }
        opkg install python3-pip || { echo "Gagal menginstal pip3. Pastikan repositori OpenWrt dikonfigurasi dengan benar."; exit 1; }
        if ! command_exists "$PIP_CMD"; then
            echo "Gagal menginstal pip3. Silakan instal secara manual: opkg update && opkg install python3-pip"
            exit 1
        fi
    fi
    echo "Python dan pip sudah siap."
}


echo "=================================================="
echo "  Installer Script untuk ZTE MF90 Modem Rebooter  "
echo "           (Tested OpenWrt STB B860H)             "
echo "=================================================="
echo ""

read -p "Apakah ingin menginstal Internet Detector? (y/n): " install_detector_choice
echo ""

if [ "$install_detector_choice" = "y" ] || [ "$install_detector_choice" = "Y" ]; then
    echo "Memulai instalasi Internet Detector..."
    opkg update || { echo "Gagal update opkg. Cek koneksi internet."; exit 1; }

    echo "Mengunduh dan menginstal internet-detector..."
    wget --no-check-certificate -O /tmp/internet-detector_1.6.0-r1_all.ipk https://github.com/gSpotx2f/packages-openwrt/raw/master/current/internet-detector_1.6.0-r1_all.ipk || { echo "Gagal mengunduh internet-detector."; exit 1; }
    opkg install /tmp/internet-detector_1.6.0-r1_all.ipk || { echo "Gagal menginstal internet-detector."; exit 1; }
    rm /tmp/internet-detector_1.6.0-r1_all.ipk

    echo "Mengaktifkan layanan internet-detector..."
    service internet-detector start
    service internet-detector enable

    echo "Mengunduh dan menginstal luci-app-internet-detector..."
    wget --no-check-certificate -O /tmp/luci-app-internet-detector_1.6.0-r1_all.ipk https://github.com/gSpotx2f/packages-openwrt/raw/master/current/luci-app-internet-detector_1.6.0-r1_all.ipk || { echo "Gagal mengunduh luci-app-internet-detector."; exit 1; }
    opkg install /tmp/luci-app-internet-detector_1.6.0-r1_all.ipk || { echo "Gagal menginstal luci-app-internet-detector."; exit 1; }
    rm /tmp/luci-app-internet-detector_1.6.0-r1_all.ipk
    
    echo "Merestart layanan rpcd..."
    service rpcd restart

    echo "Internet Detector berhasil diinstal."
    echo ""
else
    echo "Melewatkan instalasi Internet Detector."
    echo ""
fi

MODEM_IP=""
while true; do
    read -p "Berapa IP Modem ZTE MF90? (contoh: 192.168.0.1): " MODEM_IP
    if echo "$MODEM_IP" | grep -Eq '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'; then
        echo "IP Modem yang dimasukkan: $MODEM_IP"
        break
    else
        echo "Format IP tidak valid. Harap masukkan format seperti 192.168.0.1"
    fi
done
echo ""

MODEM_PASSWORD=""
read -s -p "Masukkan password modem ZTE MF90: " MODEM_PASSWORD
echo "" 

echo "Meng-encode password modem..."
MODEM_PASSWORD_ENCODED=$(echo -n "$MODEM_PASSWORD" | "$PYTHON_CMD" -c 'import base64, sys; print(base64.b64encode(sys.stdin.buffer.read()).decode())')
echo "Password modem telah berhasil di-encode."
echo ""

install_python_pip

echo "requests" > "$REQUIREMENTS_PATH"
echo "Membuat $REQUIREMENTS_FILE di $REQUIREMENTS_PATH"

echo "Menginstal dependensi Python dari $REQUIREMENTS_FILE..."
"$PIP_CMD" install -r "$REQUIREMENTS_PATH" || { echo "Gagal menginstal dependensi Python. Coba jalankan 'opkg update' dan 'opkg install python3-pip' secara manual."; exit 1; }
rm "$REQUIREMENTS_PATH"
echo "Dependensi Python berhasil diinstal."
echo ""

echo "Membuat script $REBOOT_SCRIPT_NAME di $REBOOT_SCRIPT_PATH..."
cat << EOF > "$REBOOT_SCRIPT_PATH"
#! /usr/bin/env python3
import requests
import time
import base64
from requests.exceptions import RequestException
from sys import exit

class ModemRebooter:
    def __init__(self, ip, password_encoded, reboot_timeout=90):
        self.modem_ip = ip
        self.modem_password_encoded = password_encoded
        self.reboot_timeout = reboot_timeout
        self.base_url = f'http://{self.modem_ip}/goform/goform_set_cmd_process'
        self.headers = {
            'Accept': 'application/json, text/javascript, */*; q=0.01',
            'Content-Type': 'text/plain',
            'Origin': f'http://{self.modem_ip}',
            'Referer': f'http://{self.modem_ip}/index.html',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0',
        }

    def _send_post_request(self, payload):
        try:
            response = requests.post(self.base_url, data=payload, headers=self.headers, timeout=10)
            response.raise_for_status()
            return response
        except RequestException as e:
            print(f"Error saat kirim permintaan ke modem: {e}")
            return None

    def _check_modem_reachability(self):
        print(f"Cek modem di {self.modem_ip}...")
        try:
            requests.get(f'http://{self.modem_ip}', timeout=5).raise_for_status()
            print("Modem ready.")
            return True
        except RequestException:
            print(f"Gabisa konek ke modem di {self.modem_ip}. Cek IP sama pastiin modem aktif.")
            return False
        
    def _is_modem_reachable_silent(self):
        try:
            requests.get(f'http://{self.modem_ip}', timeout=5).raise_for_status()
            return True
        except RequestException:
            return False
    
    def _perform_login(self):
        print("Nyoba login ke modem...")
        payload = {'isTest': 'false', 'goformId': 'LOGIN', 'password': self.modem_password_encoded}
        response = self._send_post_request(payload)
        if response and response.status_code == 200:
            print("Anjay jadi!")
            return True
        else:
            print("Gagal login ke modem. Password udah bener?.")
            return False

    def _wait_for_modem_online(self):
        print("Perintah reboot udah dikirim.")
        print("Tunggu modem sampe online bang sekitar 20 detik.")

        start_time = time.time()
        while time.time() - start_time < self.reboot_timeout:
            if self._is_modem_reachable_silent():
                print("\nModem berhasil direstart!")
                return True
            print(".", end="", flush=True)
            time.sleep(1)
        
        print("\nTimeout: Modem ga ngerespon, coba cek modem.")
        return False

    def initiate_reboot_process(self):
        if not self._check_modem_reachability():
            return False

        if not self._perform_login():
            print("Proses reboot gagal karena gabisa login.")
            return False

        print("Nyuruh modem reboot...")
        reboot_payload = {'isTest': 'false', 'goformId': 'REBOOT_DEVICE'}
        self._send_post_request(reboot_payload)
        time.sleep(5) # Give modem a moment to start rebooting
        return self._wait_for_modem_online()

def main():
    MODEM_IP = '$MODEM_IP' 
    MODEM_PASSWORD_ENCODED = '$MODEM_PASSWORD_ENCODED' 

    print('Script reboot MF90 by JotaroTol')
    print(f"IP: {MODEM_IP} dan Password (encoded): '{MODEM_PASSWORD_ENCODED}'")
    print("-" * 50)

    rebooter = ModemRebooter(MODEM_IP, MODEM_PASSWORD_ENCODED)

    try:
        if rebooter.initiate_reboot_process():
            print("Proses reboot modem aman terkendali.")
        else:
            print("Proses reboot modem gagal total.")
    except Exception as e:
        print(f"Terjadi kesalahan tak terduga selama proses: {e}")
    finally:
        print("\nProgram berakhir.")
        print("by JotaroTol.")

if __name__ == "__main__":
    main()
EOF

chmod +x "$REBOOT_SCRIPT_PATH"
echo "Script $REBOOT_SCRIPT_NAME berhasil dibuat dan dibuat executable."
echo ""

if [ "$install_detector_choice" = "y" ] || [ "$install_detector_choice" = "Y" ]; then
    DOWN_SCRIPT_PATH="/etc/internet-detector/down-script.internet"
    REBOOT_COMMAND="/usr/bin/python3 $REBOOT_SCRIPT_PATH"

    echo "Menambahkan perintah reboot ke $DOWN_SCRIPT_PATH..."
    if ! grep -q "$REBOOT_COMMAND" "$DOWN_SCRIPT_PATH"; then
        echo "$REBOOT_COMMAND" >> "$DOWN_SCRIPT_PATH"
        echo "Perintah '$REBOOT_COMMAND' berhasil ditambahkan ke $DOWN_SCRIPT_PATH."
    else
        echo "Perintah '$REBOOT_COMMAND' sudah ada di $DOWN_SCRIPT_PATH. Melewatkan penambahan."
    fi
    echo ""
fi


echo "=================================================="
echo "  Instalasi Selesai!                               "
echo "=================================================="
echo "Sekarang dapat menjalankan script reboot dengan perintah:"
echo "/usr/bin/python3 $REBOOT_SCRIPT_PATH"
echo ""
echo "Terima kasih telah menggunakan script ini!"
echo "by JotaroTol."
