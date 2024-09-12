#!/bin/bash

# Detect OS
OS="`uname`"
case $OS in
  'Linux')
    OS='Linux'
    package_manager="sudo apt-get install -y" # Use apt for Ubuntu/Debian; modify for other distros
    ;;
  'Darwin') 
    OS='Mac'
    package_manager="brew install"
    ;;
  'WindowsNT') 
    OS='Windows'
    # Assuming you're using WSL
    package_manager="sudo apt-get install -y"
    ;;
  *) ;;
esac

echo "Detected OS: $OS"

# Install dependencies (modify according to OS)
if [ "$OS" = "Linux" ] || [ "$OS" = "Mac" ]; then
  echo "Installing dependencies..."
  $package_manager tmux
  $package_manager neovim
  $package_manager git
fi

# Clone dotfiles repository
echo "Cloning dotfiles..."
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles

# Symlink configuration files
echo "Setting up symlinks..."
ln -sf ~/.dotfiles/nvim ~/.config/nvim
ln -sf ~/.dotfiles/.tmux.conf ~/.tmux.conf

# Install Tmux Plugin Manager
echo "Installing Tmux Plugin Manager..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

echo "Installation complete!"

