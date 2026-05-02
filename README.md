# TP-Link Archer T2U Plus — Wi-Fi Driver Installer for Kali Linux

> One-command installer for the **RTL8821AU** chipset driver on Kali Linux. No manual compilation or complex setup required.

![License](https://img.shields.io/badge/License-MIT-green.svg)
![Platform](https://img.shields.io/badge/Platform-Kali%20Linux-blue.svg)
![Kernel](https://img.shields.io/badge/Kernel-6.12.25--amd64-orange.svg)
![Chipset](https://img.shields.io/badge/Chipset-RTL8821AU-red.svg)

---

## 📋 Overview

This repository provides a professional-grade Bash script that automates the full installation and configuration of the **TP-Link Archer T2U Plus (AC600)** Wi-Fi adapter driver on Kali Linux.

| Detail | Value |
|---|---|
| **Supported OS** | Kali Linux (amd64) |
| **Kernel Version** | 6.12.25-amd64 |
| **Device** | TP-Link Archer T2U Plus |
| **Chipset** | RTL8821AU |
| **License** | MIT (free for personal use) |

---

## ⚙️ What the Script Does

- **Downloads** the required kernel headers (`linux-headers-6.12.25-*`) directly from Kali mirrors.
- **Clones** the [`morrownr/8821au-20210708`](https://github.com/morrownr/8821au-20210708) driver repository.
- **Optional Cleanup** — removes old or corrupted drivers (e.g., `88XXau`) with a deep clean option.
- **Installs** the driver by configuring headers via `dpkg -i` and deploying using `install-driver.sh`.

---

## 🚀 Quick Start

### Prerequisites

Make sure you have the following before proceeding:

- Kali Linux (amd64, kernel `6.12.25-amd64`)
- An active internet connection
- `sudo` privileges

Install the required dependencies:

```bash
sudo apt install wget git dkms
```

---

### Installation Steps

**1. Clone this repository:**

```bash
git clone https://github.com/R-S-Nithesh/AC600-Wifi-Driver.git
```

**2. Navigate into the directory:**

```bash
cd AC600-Wifi-Driver
```

**3. Make the script executable:**

```bash
chmod +x setup_t2u_plus.sh
```

**4. Run the installer:**

```bash
sudo ./setup_t2u_plus.sh
```

**5. Follow the on-screen prompts** to select your installation option. The script will handle the rest.

**6. Reboot your system** once the installation completes (or reboot manually):

```bash
sudo reboot
```

**7. Plug in your TP-Link Archer T2U Plus** adapter after rebooting — available Wi-Fi networks should now appear.

---

## 📁 Repository Structure

```
AC600-Wifi-Driver/
└── setup_t2u_plus.sh   # Main installer script
```

---

## 🛠️ Troubleshooting

- **Kernel mismatch** — Ensure your running kernel matches `6.12.25-amd64`. Check with `uname -r`.
- **DKMS errors** — Make sure `dkms` is installed: `sudo apt install dkms`.
- **Old driver conflicts** — Select the cleanup/deep clean option when prompted by the script.
- **No networks after reboot** — Unplug and re-plug the USB adapter, then run `ip link` to verify the interface is detected.

---

## 📄 License

This project is licensed under the **MIT License** — free for personal use.  
See the [LICENSE](LICENSE) file for full details.

---

## 🙏 Credits

Driver source: [morrownr/8821au-20210708](https://github.com/morrownr/8821au-20210708)
