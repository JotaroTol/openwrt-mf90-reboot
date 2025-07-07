# ZTE MF90 Modem Rebooter untuk OpenWrt (STB B860H)

Script untuk me-reboot modem ZTE MF90 dari perangkat OpenWrt. Ini sangat berguna untuk otomatisasi reboot modem, terutama ketika dikombinasikan dengan Internet Detector agar anti bengong.

---

## Fitur Utama

* **Reboot Otomatis:**
* **Integrasi Internet Detector (Opsional):** Installer dapat secara opsional menginstal Internet Detector dan mengkonfigurasi `reboot.py` untuk berjalan secara otomatis ketika koneksi internet terputus, memastikan pemulihan yang cepat.
* **Konfigurasi Dinamis:** Alamat IP modem dan password dikonfigurasi secara dinamis selama proses instalasi.

---

## Persyaratan Sistem

Untuk menjalankan proyek ini, Anda membutuhkan:

* Perangkat OpenWrt.
* Modem ZTE MF90.

---

## Instalasi

Ikuti langkah-langkah di bawah ini di terminal OpenWrt Anda:

* **Jalankan Script di Terminal**

    ```bash
    wget --no-check-certificate -O /tmp/install.sh https://github.com/YourUsername/YourRepoName/raw/main/install.sh
    chmod +x /tmp/install.sh
    /tmp/install.sh
    ```

    * **Instal Internet Detector?** (y/n):
        * Pilih `y` jika Anda ingin menginstal Internet Detector untuk deteksi internet otomatis dan mengintegrasikan skrip reboot.
        * Pilih `n` jika Anda hanya ingin menginstal skrip reboot.

    * **IP Modem ZTE MF90:** Masukkan alamat IP modem Anda (contoh: `192.168.0.1`).

    * **Password Modem:** Masukkan password modem Anda (input akan tersembunyi untuk keamanan).
---

## Penggunaan

Setelah instalasi selesai, konfigurasi Internet Detector sesuai yg diinginkan

## Kredit
* **JotaroTol:**
* **gSpotx2f:** Internet Detector OpenWrt.