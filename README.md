# Dotfiles for Neovim & Tmux

This repository contains my personal configuration for Neovim and Tmux, along with a script that automates the setup across multiple platforms (Linux, macOS, and Windows via WSL). It ensures that my development environment is consistently set up on any device.

## Features

- **Neovim configuration** with essential plugins and settings.
- **Tmux configuration** with a plugin manager (TPM) for easy plugin management.
- **Cross-platform installation script** for Linux, macOS, and Windows (via WSL).

## Installation

You can set up your development environment by running a simple command. This will clone the repository, install the necessary dependencies, and set up the configurations.

### Step 1: Clone and Run the Installation Script

```bash
curl -o- https://raw.githubusercontent.com/vikyathshirva/dotfiles/main/install.sh | bash
```

### Step 2: Tmux Plugin Manager

After installing the configuration, open a Tmux session and press `prefix + I` (default is `Ctrl + b + I`) to install the Tmux plugins.

## What Does the Script Do?

1. **Detects your operating system** (Linux, macOS, or Windows via WSL).
2. **Installs the required dependencies** like Neovim, Tmux, and Git using the appropriate package manager for your system.
3. **Clones this repository** to `~/.dotfiles`.
4. **Creates symlinks** for Neovim and Tmux configuration files.
5. **Installs the Tmux Plugin Manager (TPM)** and sets up Tmux plugins.

## Manual Installation

If you prefer to manually set up the environment, follow these steps:

1. Clone this repository:

   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
   ```

2. Symlink the configuration files:

   ```bash
   ln -sf ~/.dotfiles/nvim ~/.config/nvim
   ln -sf ~/.dotfiles/.tmux.conf ~/.tmux.conf
   ```

3. Install the Tmux Plugin Manager:

   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```

4. Open Tmux and press `prefix + I` to install plugins.

## Customization

Feel free to modify the Neovim and Tmux configurations to suit your workflow. The config files are located in:

* Neovim: `~/.dotfiles/nvim`
* Tmux: `~/.dotfiles/.tmux.conf`

## Compatibility

* **Linux**: Tested with Ubuntu, Debian, and Arch.
* **macOS**: Works with Homebrew.
* **Windows**: Works via **WSL** (Windows Subsystem for Linux).

## Contributions

If you'd like to improve the setup or suggest any changes, feel free to open an issue or submit a pull request!

## License

This project is open-source and available under the MIT License.
