#!/bin/bash

#Vefify if the user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi
                                        
#Update the system
apt update && apt upgrade -y

# Ask the user if they want to install Zsh with Kitty
echo -e "\n Do you want to replace Gnome-Terminal for ZSH with Kitty (y/n)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo -e "\n Installing Zsh and Kitty..."
    
    # Install Zsh and Kitty
    apt install -y zsh kitty

    # Install Cascadia Code Nerd Font 
    echo -e "\n Downloading and installing Cascadia Code Nerd Font..."
    mkdir -p ~/.local/share/fonts
    wget -O /tmp/CascadiaCode.zip \
         "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
    unzip -o /tmp/CascadiaCode.zip -d ~/.local/share/fonts/
    fc-cache -fv  # Reload the font cache

    # Configure Kitty to use Cascadia Code
    echo -e "\n Setting Up Kitty to use Cascadia Code."
    mkdir -p ~/.config/kitty
    echo "font_family Cascadia Code" > ~/.config/kitty/kitty.conf
    echo "bold_font Cascadia Code Bold" >> ~/.config/kitty/kitty.conf
    echo "italic_font Cascadia Code Italic" >> ~/.config/kitty/kitty.conf
    echo "bold_italic_font Cascadia Code Bold Italic" >> ~/.config/kitty/kitty.conf
    echo "enable_ligatures always" >> ~/.config/kitty/kitty.conf

    # Set Zsh as the default shell
    echo -e "\n Configurando Zsh como shell predeterminado..."
    chsh -s $(which zsh) $SUDO_USER

    echo -e "\n Zsh and Kitty have been installed correctly with Cascadia Code as the default font."
    

else
    echo -e "\n Se mantendrá gnome-terminal como terminal predeterminada."
fi

