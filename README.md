# ZTE MF90 Modem Rebooter untuk OpenWrt

Script untuk me-reboot modem ZTE MF90 dari perangkat OpenWrt. Praktis untuk otomatisasi reboot modem, terutama ketika dikombinasikan dengan Internet Detector agar anti bengong.

---

## Fitur Utama

* **Reboot Otomatis**
* **Integrasi Internet Detector (Opsional):** Installer dapat secara opsional menginstal Internet Detector dan mengkonfigurasi `reboot.py` untuk berjalan secara otomatis ketika koneksi internet terputus.

---

## Persyaratan Sistem


* Perangkat OpenWrt.
* Modem ZTE MF90.

---

## Instalasi

* **Jalankan Script di Terminal**

    ```bash
    get --no-check-certificate -O /tmp/install.sh https://raw.githubusercontent.com/JotaroTol/openwrt-mf90-reboot/refs/heads/master/install.sh
    chmod +x /tmp/install.sh
    /tmp/install.sh
    ```

* **Instal Internet Detector?** (y/n):
  * Pilih `y` jika ingin menginstal Internet Detector untuk deteksi internet otomatis dan mengintegrasikan skrip reboot.
  * Pilih `n` jika hanya ingin menginstal skrip reboot.

* **IP Modem ZTE MF90:** Masukkan alamat IP modem (contoh: `192.168.0.1`).

* **Password Modem:** Masukkan password modem Anda (input akan tersembunyi untuk keamanan).
---

## Penggunaan

Setelah instalasi selesai, konfigurasi Internet Detector sesuai yg diinginkan atau manual gunakan (`/usr/bin/python3 usr/bin/reboot.py`)

## Kredit
* **JotaroTol**
* **gSpotx2f:** Internet Detector OpenWrt.
