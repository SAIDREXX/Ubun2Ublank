#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Verify if the script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Get current path
temp_path=$(pwd)

# Update the system
sudo apt update

# Create a temporary directory for setup
mkdir ~/requirements

# Install Polybar dependencies
sudo apt install -y cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev \
  libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto \
  libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-xkb-dev libxcb-xrm-dev \
  libxcb-cursor-dev libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev \
  libuv1-dev libnl-genl-3-dev

# Install Picom dependencies
sudo apt install -y meson libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev \
  libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-composite0-dev \
  libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libpixman-1-dev libdbus-1-dev \
  libconfig-dev libgl1-mesa-dev libpcre2-dev libevdev-dev uthash-dev libev-dev \
  libx11-xcb-dev libxcb-glx0-dev libpcre3 libpcre3-dev

# Install miscellaneous packages
sudo apt install -y feh flameshot zsh rofi xclip bat locate neofetch wmname acpi \
  bspwm sxhkd imagemagick ranger kitty

# Clone the necessary repositories
cd ~/requirements
git clone --recursive https://github.com/polybar/polybar
git clone https://github.com/ibhagwan/picom.git

# Install Polybar
cd ~/requirements/polybar && mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install

# Install Picom
cd ~/requirements/picom && git submodule update --init --recursive
meson --buildtype=release . build
ninja -C build
sudo ninja -C build install

# Install Powerlevel10k for the current user
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

# Install Powerlevel10k for the root user
sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.powerlevel10k

# Set up Nord theme for Rofi
mkdir -p ~/.config/rofi/themes
cp "$temp_path/rofi/nord.rasi" ~/.config/rofi/themes/

# Install LSD (if the package is available in temp_path)
sudo dpkg -i "$temp_path/lsd.deb"

# Install NerdFont
sudo cp -v "$temp_path/fonts/"* /usr/local/share/fonts/

# Install Polybar fonts
sudo cp -v "$temp_path/Config/polybar/fonts/"* /usr/share/fonts/truetype/

# Set up wallpapers
mkdir -p ~/wallpaper ~/screenshots
cp -v "$temp_path/assets/"* ~/wallpaper/

# Copy configuration files
cp -rv "$temp_path/config/"* ~/.config/
sudo cp -rv "$temp_path/kitty" /opt/

# Configure Kitty for the root user
sudo cp -rv "$temp_path/config/kitty" /root/.config/

# Copy .p10k.zsh and .zshrc files
rm -rf ~/.zshrc
cp -v "$temp_path/.p10k.zsh-root" /root/.p10k.zsh

# Install ZSH plugins
sudo apt install -y zsh-syntax-highlighting zsh-autosuggestions zsh-autocomplete
sudo mkdir -p /usr/share/zsh-sudo
cd /usr/share/zsh-sudo
sudo wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh

# Set ZSH as the default shell
chsh -s /usr/bin/zsh
sudo usermod --shell /usr/bin/zsh root
sudo ln -s -fv ~/.zshrc /root/.zshrc

# Assign execution permissions to necessary scripts
chmod +x ~/.config/bspwm/bspwmrc
chmod +x ~/.config/bspwm/scripts/bspwm_resize
chmod +x ~/.config/bin/ethernet_status.sh
chmod +x ~/.config/bin/htb_status.sh
chmod +x ~/.config/bin/htb_target.sh
chmod +x ~/.config/polybar/launch.sh

# Set up Rofi theme
rofi-theme-selector

# Clean up installation files
rm -rf ~/requirements

# Notify the user that everything is ready
echo "Ubuntu is now Ublank. Please restart your system to apply changes."