sudo pacman -Syu --noconfirm
sudo pacman -S --needed base-devel git

if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd ../
fi

terminal=(
    "kitty"                       # Terminal emulator
    "oh-my-posh"                  # Terminal prompt
    "tmux"                        # Terminal multiplexer
    "zsh"                         # Shell
)

cli_tools=(
    "brightnessctl"               # Brightness Control
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
    "unzip"                       # Unzipping tool
    "curl"                        # Transfer data with urls
)

prog_langs=(
    "clang"                       # [C/C++] Clang
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
    "vlc"                         # Media Player
    "libreoffice"                 # File processing software
    "obs-studio"                  # Screen recording
    "nautilus"                    # File Explorer
    "rofi-wayland"                # Application launcher
    "wlogout"                     # Logout Screen
)

fonts=(
    "noto-fonts"
    "noto-fonts-cjk"
    "noto-fonts-emoji"
    "noto-fonts-extra"
    "otf-font-awesome"
    "ttf-dejavu"
    "ttf-firacode-nerd"
    "ttf-fira-sans"
    "ttf-nerd-fonts-symbols"
    "ttf-nerd-fonts-symbols-common"
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
    "bibata-cursor-git"           # Cursor Theme
)

packages=(
    "${terminal[@]}"
    "${cli_tools[@]}"
    "${fonts[@]}"
    "${prog_langs[@]}"
    "${gui_apps[@]}"
    "${other[@]}"
)

for pkg in "${packages[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done

sudo fc-cache -f -v

# Installs zplug
if command -v zplug &> /dev/null; then
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
fi 

# change shell to zsh
if [ "$(which $SHELL)" != "/usr/bin/zsh" ]; then
    chsh -s $(which zsh)
fi

# install nvim config
mkdir nvim-temp
git clone https://github.com/Daniel-Cocos/nvim-config.git nvim-temp
cp -r ./nvim-temp/nvim ~/.config
rm -rf nvim-temp


# move dotfiles
mkdir -p ~/.config

rm -rf ~/.config
rm -rf ~/.fonts
rm -rf ~/.themes
rm -rf ~/dev

cp -r ./home/dev ~/dev
cp -r ./home/fonts ~/.fonts
cp -r ./home/config ~/.config
cp -r ./home/themes ~/.themes
cp -r ./home/scripts ~/.scripts
cp -r ./home/wallpapers ~/.wallpapers
cp -r ./home/applications/* ~/.local/share/applications

cp ./home/tmux.conf ~/.tmux.conf
cp ./home/zshrc ~/.zshrc

