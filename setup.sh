#!/bin/bash

LOCAL_CONFIG="$HOME/.config/shell/local.sh"
SUBLINE_TEXT_NOTE="$HOME/Dev/subline-text"

declare -a common_packages=(
    curl wget git zsh tmux bat fzf eza unzip neovim ripgrep ncdu ranger vim zoxide
)

install_arch() {
    sudo pacman -S "${common_packages[@]}" github-cli fd git-delta lazygit ttf-firacode-nerd wl-clipboard topgrade
}

install_fedora() {
    sudo dnf copr enable atim/lazygit -y
    sudo dnf install "${common_packages[@]}" gh lazygit fd-find wl-clipboard git-delta
}

install_packages_olivia() {
    sudo apt-get update \
      && sudo apt-get install --no-install-recommends -y \
      build-essential \
      openssh-server \
      netcat \
      build-essential \
      curl \
      gettext \
      git \
      libpq-dev \
      python3-openssl \
      python3-mysqldb \
      libmagic1 \
      pkg-config \
      libxmlsec1-dev \
      default-libmysqlclient-dev \
      mysql-client \
      libkrb5-dev \
      libssl-dev \
      zlib1g-dev \
      ffmpeg \
      libcairo2 \
      wkhtmltopdf \
      && update-ca-certificates

    sudo apt-get install lzma
    sudo apt-get install liblzma-dev
    sudo apt-get install libbz2-dev
    sudo apt-get install libncurses-dev
    sudo apt install libreadline-dev
    sudo apt-get install libsqlite3-dev
    sudo apt-get install python3-tk python-tk
    pyenv install 3.11.7
    pyenv global 3.11.7
    curl -sSL https://install.python-poetry.org | POETRY_VERSION=1.8.2 python3 -
    pyenv virtualenv 3.11.7 venv311ui
    pyenv virtualenv 3.11.7 venv311core
}

# UBUNTU
install_debian() {
    sudo apt install git-all
    curl https://pyenv.run | bash
    pyenv update
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    npm i pnpm@8 --global
    curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list && sudo apt update && sudo apt install ngrok
    ngrok config add-authtoken token_key
    sudo apt install cmake extra-cmake-modules build-essential libkf5runner-dev libkf5textwidgets-dev qtdeclarative5-dev gettext stow yadm
}

install_termux() {
    pkg install "${common_packages[@]}" gh fd git-delta openssh termux-tools nala
    ln -sfnv "$PWD/../config/bin" "$HOME"/bin
    cp -rv "$PWD/../config/.termux" "$HOME"/
}

get_system_info() {
    [ -e /etc/os-release ] && source /etc/os-release && echo "${ID:-Unknown}" && return
    [ -e /etc/lsb-release ] && source /etc/lsb-release && echo "${DISTRIB_ID:-Unknown}" && return
    [ "$(uname)" == "Darwin" ] && echo "mac" && return
    [ "$(uname -o)" == "Android" ] && echo "termux" && return
}

install_packages() {
    system_kind=$(get_system_info)
    echo -e "\033[7m Installing packages for $system_kind...\033[0m"

    color=""
    case $system_kind in
    manjaro) color="040" && install_arch ;;
    arch) color="033" && install_arch ;;
    ubuntu) color="202" && install_debian ;;
    debian) color="163" && install_debian ;;
    fedora | fedora-asahi-remix) color="32" && install_fedora ;;
    pop) color="045" && install_debian ;;
    kali) color="254" && install_debian ;;
    termux) color="040" && install_termux ;;
    mac) color="254" ;;
    *) echo "Unknown system!" && exit 1 ;;
    esac

    echo "export POWERLEVEL9K_OS_ICON_BACKGROUND='$color'" >>"$LOCAL_CONFIG"
    echo "export POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{238}╰%F{$color}%K{$color}%F{black}  %f%F{$color}%k%f'" >>"$LOCAL_CONFIG"

    mkdir -p "$HOME/.local/state/vim/undo"
}

install_oh_my_zsh() {
    echo -e "\033[7m Installing oh-my-zsh and plugins...\033[0m"
    sudo apt install zsh -y

    zsh_dir="$HOME/.config/zsh"
    export ZDOTDIR="$zsh_dir"

    sh -c "$(curl -fsSL https://install.ohmyz.sh)" "" --unattended --keep-zshrc

    gh="https://github.com/"
    omz="$zsh_dir/ohmyzsh/custom"
    omz_plugin="$omz/plugins/"
    mkdir -p $omz_plugin

    git clone "$gh/romkatv/powerlevel10k" "$omz/themes/powerlevel10k" --depth 1

    cd "$omz_plugin" || exit
    git clone "$gh/zsh-users/zsh-autosuggestions"
    git clone "$gh/zsh-users/zsh-syntax-highlighting"
    git clone "$gh/zsh-users/zsh-history-substring-search"
    git clone "$gh/clarketm/zsh-completions"
    cd - || exit

    chsh -s "$(which zsh)"
}

install_docker() {
    echo -e "\033[7m Installing Docker...\033[0m"
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    #Install the Docker packages.
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo docker --version
    sudo docker-compose --version
}

install_extras() {
    install_oh_my_zsh
}

declare -a config_dirs=(
    "zsh"  "yadm"
)

declare -a home_files=(
    "zsh/.zshenv" "zsh/.zsh_history" ".prettierrc" ".aws" ".ssh" "Docker"
)

backup_configs() {
    echo -e "\033[33;1m Backing up existing files... \033[0m"
    for dir in "${config_dirs[@]}"; do
        mv -v "$HOME/.config/$dir" "$HOME/.config/$dir.old"
    done
    for file in "${home_files[@]}"; do
        mv -v "$HOME/$file" "$HOME/$file.old"
    done
    echo -e "\033[36;1m Done backing up files as '.old'! . \033[0m"
}

olivia_symlinks() {
    echo -e "\033[7m Setting up Olivia Symlinks... \033[0m"
    ln -sfnv "$SUBLINE_TEXT_NOTE/.dotfiles/olivia/ui/config.env" "$WORK_OLIVIA_UI/"
    ln -sfnv "$SUBLINE_TEXT_NOTE/.dotfiles/olivia/ui/.vscode" "$WORK_OLIVIA_UI/"
    ln -sfnv "$SUBLINE_TEXT_NOTE/.dotfiles/olivia/core/config.env" "$WORK_OLIVIA_CORE/"
    ln -sfnv "$SUBLINE_TEXT_NOTE/.dotfiles/olivia/core/.vscode" "$WORK_OLIVIA_CORE/"
    ln -sfnv "$SUBLINE_TEXT_NOTE/.dotfiles/olivia/core/.vscode" "$WORK_OLIVIA_CORE/"
    ln -sfnv "$SUBLINE_TEXT_NOTE/.dotfiles/olivia/media-service/.env" "$WORK_OLIVIA_MEDIA/config/"
}

setup_symlinks() {
    echo -e "\033[7m Setting up symlinks... \033[0m"
    for dir in "${config_dirs[@]}"; do
        ln -sfnv "$SUBLINE_TEXT_NOTE/.dotfiles/config/$dir" "$HOME/.config"
    done
    for file in "${home_files[@]}"; do
        ln -sfnv "$SUBLINE_TEXT_NOTE/.dotfiles/config/$file" "$HOME"
    done
}

setup_dotfiles() {
    echo -e "\033[7m Setting up dotfiles... \033[0m"
    backup_configs
    setup_symlinks
    install_packages
    install_extras
    echo -e "\033[7m Done! \033[0m"
}

install_ibus_gotv() {
    sudo add-apt-repository ppa:bamboo-engine/ibus-bamboo
    sudo apt-get update
    sudo apt-get install ibus ibus-bamboo --install-recommends
    ibus restart
    # Đặt ibus-bamboo làm bộ gõ mặc định
    env DCONF_PROFILE=ibus dconf write /desktop/ibus/general/preload-engines "['BambooUs', 'Bamboo']" && gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('ibus', 'Bamboo')]"
}

show_menu() {
    echo -e "\033[32;1m Setting up your env with dotfiles...\033[0m"
    echo -e " \033[37;1m\033[4mSelect an option:\033[0m"
    echo -e "  \033[34;1m (0) Setup Everything \033[0m"
    echo -e "  \033[34;1m (1) Backup Current Configs \033[0m"
    echo -e "  \033[34;1m (2) Setup Symlinks \033[0m"
    echo -e "  \033[34;1m (3) Install Packages \033[0m"
    echo -e "  \033[34;1m (4) Install Extras(ZSH) \033[0m"
    echo -e "  \033[34;1m (5) Install Docker \033[0m"
    echo -e "  \033[34;1m (6) Setup Olivia Symlinks \033[0m"
    echo -e "  \033[34;1m (7) Go tieng Viet \033[0m"
    echo -e "  \033[31;1m (*) Anything else to exit \033[0m"
    echo -en "\033[32;1m ==> \033[0m"

    read -r option
    case $option in
    "1") backup_configs ;;
    "2") setup_symlinks ;;
    "3") install_packages ;;
    "4") install_extras ;;
    "5") install_docker ;;
    "6") olivia_symlinks ;;
    "7") install_ibus_gotv ;;
    *) echo -e "\033[31;1m Invalid option and goodbye! \033[0m" && exit 0 ;;
    esac
}

main() {
    case "$1" in
    -a | --all | a | all) setup_dotfiles ;;
    -i | --install | i | install) setup_symlinks && install_packages && install_extras ;;
    -s | --symlinks | s | symlinks) setup_symlinks ;;
    *) show_menu ;;
    esac
    exit 0
}

main "$@"
