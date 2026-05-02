#!/bin/bash

# ANSI color codes for emphasis
RED='\033[1;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script as root (use sudo)."
  exit 1
fi

# Function to check if a command is available
command_exists() {
  command -v "$1" >/dev/null 2>&1 || { echo "Error: $1 is not installed. Install it using 'sudo apt install $1'."; exit 1; }
}

# Check for required tools
for cmd in wget git dpkg; do
  command_exists "$cmd"
done

echo -e "${RED}${BOLD}"
cat << 'EOF'
 ____        ____        _   _ 
|  _ \      / ___|      | \ | |
| |_) |     \___ \      |  \| |
|  _ <   _   ___) |  _  | |\  |    
|_| \_\ (_) |____/  (_) |_| \_|

⠀⠀⠀⠀⠀⠀⠀⣀⣤⣶⣿⠷⠾⠛⠛⠛⠛⠷⠶⢶⣶⣤⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣀⣴⡾⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠿⣷⣄⡀⠀⠀⠀
⠀⠀⣠⣾⠟⠁⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⣤⣀⣀⡀⠀⠀⠀⠀⠈⠛⢿⣦⡀⠀
⢠⣼⠟⠁⠀⠀⠀⠀⣠⣴⣶⣿⣏⣭⣻⣛⣿⣿⣿⣷⣦⣄⠀⠀⠀⠀⠀⠙⣧⡀
⣿⡇⠀⠀⠀⢀⣴⣾⣿⣿⣿⣿⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⢈⣷
⣿⣿⣦⡀⣠⣾⣿⣿⣿⣿⡿⠛⠉⠀⠀⠀⠘⠀⠈⠻⢿⣿⣿⣿⣿⣆⣀⣠⣾⣿
⠉⠻⣿⣿⣿⣿⣽⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⣿⣿⣿⣿⣿⠟⠁
⠀⠀⠈⠙⠛⣿⣿⠀⠀⠀⠀⠀⢀⣀⣶⣦⣶⣦⣄⡀⠀⠀⠀⣹⣿⡟⠋⠁⠀⠀
⠀⠀⠀⠀⠀⠘⢿⣷⣄⣀⣴⣿⣿⣭⣭⣭⣿⣽⣿⣷⣀⣀⣾⡿⠛⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠐⠘⢿⣿⣿⣿⣿⠟⠛⠛⠻⣿⣿⣿⣿⠿⡋⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣷⣄⠀⠀⣀⣾⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠿⠿⠿⠿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
EOF

# Ask user if they want to remove old or corrupted Wi-Fi drivers
while true; do
  read -p "Do you want to remove old or corrupted Wi-Fi drivers? (y/n): " remove_drivers
  case "$remove_drivers" in
    [Yy]*|[Nn]*) break ;;
    *) echo "Please enter 'y' or 'n'." ;;
  esac
done

# Function to download a file with error checking
download_file() {
  local url="$1"
  local file="$2"
  local attempts=3
  local attempt=1
  echo "Downloading $file from $url..."
  while [ $attempt -le $attempts ]; do
    wget --timeout=10 -O "$file" "$url"
    if [ $? -eq 0 ] && [ -f "$file" ]; then
      return 0
    fi
    echo "Attempt $attempt failed for $file."
    ((attempt++))
    sleep 2
  done
  echo "Error: Failed to download $file after $attempts attempts. Check your internet connection or try a different mirror (e.g., https://kali.download/kali/)."
  exit 1
}

# Get system architecture and kernel version
arch=$(uname -m)
if [ "$arch" != "x86_64" ]; then
  echo "Error: This script supports only amd64 architecture, detected $arch."
  exit 1
fi
kernel_version=$(uname -r)
version="${kernel_version%-amd64}"  # Removes '-amd64' to get version like 6.12.25
base_url="https://http.kali.org/kali/pool/main/l/linux/"
fallback_url="https://kali.download/kali/pool/main/l/linux/"

# Define package names based on kernel version
headers_amd64="linux-headers-${version}-amd64_${version}-1kali1_amd64.deb"
headers_common="linux-headers-${version}-common_${version}-1kali1_all.deb"
kbuild="linux-kbuild-${version}_${version}-1kali1_amd64.deb"

# Construct URLs
urls=(
  "${base_url}${headers_common}"
  "${base_url}${kbuild}"
  "${base_url}${headers_amd64}"
  "${fallback_url}${headers_common}"
  "${fallback_url}${kbuild}"
  "${fallback_url}${headers_amd64}"
)

# Download the packages to the current directory
for i in 0 1 2; do
  file=$(basename "${urls[$i]}")
  if [ -f "$file" ]; then
    echo "$file already exists in $(pwd), skipping download."
    continue
  fi
  download_file "${urls[$i]}" "$file" || download_file "${urls[$((i+3))]}" "$file"
done

# Clone the driver repository to the current directory
if [ -d "8821au-20210708" ]; then
  echo "Repository already exists in $(pwd)/8821au-20210708, skipping clone."
else
  echo "Cloning driver repository..."
  git clone https://github.com/morrownr/8821au-20210708.git
  if [ $? -ne 0 ]; then
    echo "Error: Failed to clone repository. Check your internet connection or the repository URL."
    exit 1
  fi
fi

# If user chose to remove drivers, perform removal steps
if [ "$remove_drivers" = "y" ] || [ "$remove_drivers" = "Y" ]; then
  echo "Removing old or corrupted Wi-Fi drivers..."

  # Navigate to the repository and execute remove-driver.sh if it exists
  cd 8821au-20210708 || { echo "Error: Failed to enter 8821au-20210708 directory"; exit 1; }
  if [ -f "remove-driver.sh" ]; then
    echo "Executing remove-driver.sh..."
    sudo ./remove-driver.sh
    if [ $? -ne 0 ]; then
      echo "Warning: remove-driver.sh encountered an error. Continuing with deep clean."
    fi
  else
    echo "Warning: remove-driver.sh not found in 8821au-20210708 directory. Skipping."
  fi
  cd .. || { echo "Error: Failed to return to parent directory"; exit 1; }

  # Ask if the user wants to reboot after removal
  read -p "Do you want to reboot now? (Recommended: no) (y/n): " reboot_now
  if [ "$reboot_now" = "y" ] || [ "$reboot_now" = "Y" ]; then
    echo "Rebooting..."
    sudo reboot
  fi

  # Deep clean: remove kernel modules, files, and blacklists
  echo "Performing deep clean of Wi-Fi drivers..."

  # Unload the 88XXau module if loaded
  if lsmod | grep -q "88XXau"; then
    echo "Unloading 88XXau module..."
    sudo rmmod 88XXau || echo "Warning: Failed to unload 88XXau module."
  fi

  # Remove the module file
  module_path="/lib/modules/$(uname -r)/kernel/drivers/net/wireless/88XXau.ko"
  if [ -f "$module_path" ]; then
    echo "Removing module file $module_path..."
    sudo rm -f "$module_path"
    sudo depmod -a
  fi

  # Remove the 8821au-20210708 directory
  if [ -d "8821au-20210708" ]; then
    echo "Removing 8821au-20210708 directory..."
    sudo rm -rf "8821au-20210708"
  fi

  # Clean up blacklist entries
  blacklist_file="/etc/modprobe.d/blacklist-88XXau.conf"
  if [ -f "$blacklist_file" ]; then
    echo "Removing blacklist file $blacklist_file..."
    sudo rm -f "$blacklist_file"
  fi

  echo "Deep clean completed."
fi

# Install downloaded packages in sequence
echo "Installing downloaded packages..."
# Install linux-headers-6.12.25-common
if ! dpkg -l | grep -q "linux-headers-${version}-common"; then
  echo "Installing $headers_common..."
  sudo dpkg -i "$headers_common"
  if [ $? -ne 0 ]; then
    echo "Warning: Failed to install $headers_common. Attempting to fix dependencies..."
    sudo apt install -f -y || { echo "Error: Failed to fix dependencies for $headers_common. Run 'sudo apt install -f' manually."; exit 1; }
    sudo dpkg -i "$headers_common" || { echo "Error: Failed to install $headers_common even after fixing dependencies."; exit 1; }
  fi
else
  echo "$headers_common is already installed, skipping."
fi

# Install linux-kbuild-6.12.25
if ! dpkg -l | grep -q "linux-kbuild-${version}"; then
  echo "Installing $kbuild..."
  sudo dpkg -i "$kbuild"
  if [ $? -ne 0 ]; then
    echo "Warning: Failed to install $kbuild. Attempting to fix dependencies..."
    sudo apt install -f -y || { echo "Error: Failed to fix dependencies for $kbuild. Run 'sudo apt install -f' manually."; exit 1; }
    sudo dpkg -i "$kbuild" || { echo "Error: Failed to install $kbuild even after fixing dependencies."; exit 1; }
  fi
else
  echo "$kbuild is already installed, skipping."
fi

# Install linux-headers-6.12.25-amd64
if ! dpkg -l | grep -q "linux-headers-${version}-amd64"; then
  echo "Installing $headers_amd64..."
  sudo dpkg -i "$headers_amd64"
  if [ $? -ne 0 ]; then
    echo "Warning: Failed to install $headers_amd64. Attempting to fix dependencies..."
    sudo apt install -f -y || { echo "Error: Failed to fix dependencies for $headers_amd64. Run 'sudo apt install -f' manually."; exit 1; }
    sudo dpkg -i "$headers_amd64" || { echo "Error: Failed to install $headers_amd64 even after fixing dependencies."; exit 1; }
  fi
else
  echo "$headers_amd64 is already installed, skipping."
fi

# Clone the driver repository again if it was removed during deep clean
if [ ! -d "8821au-20210708" ]; then
  echo "Cloning driver repository..."
  git clone https://github.com/morrownr/8821au-20210708.git
  if [ $? -ne 0 ]; then
    echo "Error: Failed to clone repository. Check your internet connection or the repository URL."
    exit 1
  fi
fi

# Execute install-driver.sh in the 8821au-20210708 directory
cd 8821au-20210708 || { echo "Error: Failed to enter 8821au-20210708 directory"; exit 1; }
if [ ! -f "install-driver.sh" ]; then
  echo "Error: install-driver.sh not found in 8821au-20210708 directory."
  exit 1
fi
echo "Executing install-driver.sh..."
sudo ./install-driver.sh
if [ $? -ne 0 ]; then
  echo "Error: Failed to execute install-driver.sh. Please run 'sudo ./install-driver.sh' manually."
  exit 1
fi
cd .. || { echo "Error: Failed to return to parent directory"; exit 1; }

# Ask if the user wants to reboot after installation
read -p "Do you want to reboot now? (y/n): " reboot_after_install
if [ "$reboot_after_install" = "y" ] || [ "$reboot_after_install" = "Y" ]; then
  echo "Rebooting..."
  sudo reboot
fi

# Display completion message in large text
echo -e "${RED}${BOLD}"
cat << 'EOF'
  _____ _                 _     __   __          
 |_   _| |__   __ _ _ __ | | __ \ \ / /__  _   _ 
   | | | '_ \ / _` | '_ \| |/ /  \ V / _ \| | | |
   | | | | | | (_| | | | |   <    | | (_) | |_| |
   |_| |_| |_|\__,_|_| |_|_|\_\   |_|\___/ \__,_|
                                                 
EOF
echo -e "${NC}"
echo -e "${RED}${BOLD}All processes completed successfully!${NC}"
exit 0
