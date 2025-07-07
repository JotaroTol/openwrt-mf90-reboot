#! /usr/bin/env python3
import requests
import time
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
            print(f"Gabisa konek ke modem di {self.modem_ip}. Cek IPsama pastiin modem aktif.")
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
        time.sleep(5)
        return self._wait_for_modem_online()

def main():
    MODEM_IP = '192.168.0.1'
    MODEM_PASSWORD_ENCODED = 'YWRtaW4='

    print('Script reboot MF90 by JotaroTol')
    print(f"IP: {MODEM_IP} dan Password: '{MODEM_PASSWORD_ENCODED}'")
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