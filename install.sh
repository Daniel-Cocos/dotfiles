sudo pacman -Syu --noconfirm
sudo pacman -S --needed base-devel git

if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd ../
fi

terminal=(
    "fastfetch"                   # Fork of Neofetch
    "kitty"                       # Terminal emulator
    "oh-my-posh"                  # Terminal prompt
    "tmux"                        # Terminal multiplexer
    "zsh"                         # Shell
)

cli_tools=(
    "neovim"                      # Text editor
    "fzf"                         # Fuzzy Finder
    "zip"                         # Compression utility
    "ripgrep"                     # Search tool
    "fd"                          # Replacement for find
    "eza"                         # ls replacement
    "zoxide"                      # Better cd
    "yazi"                        # File manager
    "tokei"                       # Count lines of a project
    "wget"                        # Retrieve files from a network
    "curl"                        # Transfer data with urls
)

prog_langs=(
    "gcc"                         # [C/C++] C compiler
    "go"                          # [Go] golang
    "deno"                        # [JavaScript] JavaScript runtime
    "npm"                         # [JavaScript] Node package manager
    "typescript"                  # [TypeScript] JavaScript with syntax for types
    "typescript-language-server"  # [TypeScript] TypeScript Language Server Protocol
    "eslint_d"                    # [JS/TS] JavaScript / TypeScript linter
    "eslint"                      # [JS/TS] JavaScript / TypeScript linter
    "luacheck"                    # [Lua] Lua linter
    "lua"                         # [Lua] Lua
    "jdk-openjdk"                 # [Java] Java development kit
    "checkstyle"                  # [Java] Java linter
    "google-java-format"          # [Java] Java formatter
    "stylelint"                   # [CSS] CSS linter
    "markdownlint"                # [MD] Markdown linter
    "Pyright"                     # [Python] Python Language Server Protocol
    "tk"                          # [Python] Tkinter
    "python-isort"                # [Python] Utility to sort imports
    "python-poetry"               # [Python] Dependency Management
    "bash-language-server"        # [Bash] Bash Language Server Protocol
    "prettier"                    # [General] Code formatter
)

gui_apps=(    
    "brave-bin"                   # Browser
    "pavucontrol"                 # Audio control
    "pamixer"                     # Audio control interactions
    "gimp"                        # Image manipulation program
    "obs-studio"                  # Screen recording
    "rofi-wayland"                # Application launcher
    "wlogout"                     # Logout Screen
)

other=(
    "hyprland"                    # Tiling window manager
    "hyprshot"                    # Screenshot util for hyprland
    "waybar"                      # Hyprland status bar
    "swaybg"                      # Wallpaper for hyprland
    "hyprlock"                    # Lockscreen
    "wl-clipboard"                # Clipboard for wayland
    "xdg-desktop-portal-hyprland" # Screen-sharing for hyprland
    "xdg-desktop-portal"          # Screen-sharing for hyprland
    "ttf-fira-sans"               # Lock-Screen Font & other places
    "bibata-cursor-git"           # Cursor Theme
)

packages=(
    "${terminal[@]}"
    "${cli_tools[@]}"
    "${prog_langs[@]}"
    "${gui_apps[@]}"
    "${other[@]}"
)

for pkg in "${packages[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done

# Installs zplug
if command -v zplug &> /dev/null; then
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
fi 

# change shell to zsh
if [ "$(which $SHELL)" != "/usr/bin/zsh" ]; then
    chsh -s $(which zsh)
fi

# move dotfiles
mkdir -p ~/.config

rm -rf ~/.config
rm -rf ~/.fonts
rm -rf ~/.themes

cp -r ./home/config ~/.config
cp -r ./home/fonts ~/.fonts
cp -r ./home/Downloads ~/Downloads

cp -r home/wallpapers ~/.wallpapers
cp ./home/stylelintrc.js ~/.stylelintrc.js
cp ./home/tmux.conf ~/.tmux.conf
cp ./home/zshrc ~/.zshrc

# install nvim config
git clone https://github.com/Daniel-Cocos/nvim-config.git ~/.config/nvim
