#!/bin/bash

run() {
    output=$(cat /var_output)

    log INFO "FETCH VARS FROM FILES" "$output"
    name=$(cat /tmp/var_user_name)
    url_installer=$(cat /var_url_installer)
    dry_run=$(cat /var_dry_run)

    log INFO "DOWNLOAD APPS" "$output"
    apps_path="$(download-apps "$url_installer")"
    
    log INFO "APPS DOWNLOADED AT: $apps_path" "$output"
    add-multilib-repo
    log INFO "MULTILIB ADDED" "$output"
    dialog-welcome
    update-system
    log INFO "UPDATED SYSTEM" "$output"
    install-yay "$output"
    log INFO "INSTALL YAY" "$output"
    dialog-install-apps "$apps" "$dry_run" "$output"
    log INFO "APPS INSTALLED" "$output"
    disable-horrible-beep
    log INFO "HORRIBLE BEEP DISABLED" "$output"
    set-user-permissions
    log INFO "USER PERMISSIONS SET" "$output"
    
    #log INFO "CREATE DIRECTORIES" "$output"
    #create-directories
    log INFO "INSTALL DOTFILES" "$output"
    install-dotfiles
    log INFO "INSTALL GHAPPS" "$output"
    install-ghapps

    #continue-install "$url_installer" "$name"
}

log() {
    local -r level=${1:?}
    local -r message=${2:?}
    local -r output=${3:?}
    local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    echo -e "${timestamp} [${level}] ${message}" >>"$output"
}

download-apps() {
    local -r url_installer=${1:?}

    apps_path1="/tmp/paclist" 
    apps_path2="/tmp/yaylist"
    curl "$url_installer/paclist" > "$apps_path1"
    curl "$url_installer/yaylist" > "$apps_path2"

    echo $apps_path1
    echo $apps_path2
}

# Add multilib repo
add-multilib-repo() {
    echo "[multilib]" >> /etc/pacman.conf && echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
}

dialog-welcome() {
    dialog --title "Welcome!" --msgbox "Welcome to Twilight4s dotfiles and software installation script for Arch linux.\n" 10 60
}

dialog-install-apps() {
    dialog --title "Lesgoo" --msgbox \
    "The system will now install everything you need.\n\n\
    It will take some time.\n\n " 13 60
}

dialog-install-apps() {
    local file=${1:?}
    sudo pacman -S --noconfirm $(cat paclist)
    yay -S --noconfirm $(cat yaylist)
}

update-system() {
    pacman -Syu --noconfirm
}

dialog-install-apps() {
    local -r final_apps=${1:?}
    local -r dry_run=${2:?}
    local -r output=${3:?}
    
            if [ "$fixit" = "networkmanager" ]; then
                # Enable the systemd service NetworkManager.
                systemctl enable NetworkManager.service
            fi

            if [ "$fixit" = "zsh" ]; then
                # zsh as default terminal for user
                chsh -s "$(which zsh)" "$name"
            fi

            if [ "$fixit" = "docker" ]; then
                groupadd docker
                gpasswd -a "$name" docker
                systemctl enable docker.service
            fi
        else
            fake_install "$fixit"
        fi
    done
}

fake-install() {
    echo "$1 fakely installed!" >> "$output"
}

set-user-permissions() {
    dialog --infobox "Copy user permissions configuration (sudoers)..." 4 40
    curl "$url_installer/sudoers" > /etc/sudoers
}

disable-horrible-beep() {
    rmmod pcspkr
    echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf
}

#create-directories() {
#    mkdir -p "/home/$(whoami)/{Document,Download,Video,workspace,Music}"
#}

install-yay() {
    local -r output=${1:?}

    dialog --infobox "[$(whoami)] Installing \"yay\", an AUR helper..." 10 60
    curl -O "https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz" \
    && tar -xvf "yay.tar.gz" \
    && cd "yay" \
    && makepkg --noconfirm -si \
    && cd - \
    && rm -rf "yay" "yay.tar.gz" ;
}

install-dotfiles() {
    DOTFILES="/home/$(whoami)/"
    if [ ! -d "$DOTFILES" ];
        then
            dialog --infobox "[$(whoami)] Downloading dotfiles..." 10 60
            git clone --recurse-submodules "https://github.com/Twilight4/dotfiles" "$DOTFILES" >/dev/null
    fi
}


#install-ghapps() {
#    GHAPPS="/opt/github/"
#    if [ ! -d "$GHAPPS" ];
#        then
#            dialog --infobox "[$(whoami)] Downloading github apps..." 10 60
#            git clone --depth 1 "https://github.com/github-apps/apps" "$GHAPPS" >/dev/null
#            git clone --depth 1 "https://github.com/github-apps/apps" "$GHAPPS" >/dev/null
#            git clone --depth 1 "https://github.com/github-apps/apps" "$GHAPPS" >/dev/null
#            git clone --depth 1 "https://github.com/github-apps/apps" "$GHAPPS" >/dev/null
#    fi
#}

# tmux plugin manager
[ ! -d "$XDG_CONFIG_HOME/tmux/plugins/tpm" ] \
&& git clone --depth 1 https://github.com/tmux-plugins/tpm \
"$XDG_CONFIG_HOME/tmux/plugins/tpm"

# neovim plugin manager
[ ! -d "$XDG_CONFIG_HOME/.local/share/nvim/site/pack/packer/start/packer.nvim" ] \
&& git clone https://github.com/wbthomason/packer.nvim \
"$XDG_CONFIG_HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"


 #continue-install() {
#    local -r url_installer=${1:?}
#    local -r name=${2:?}

#    curl "$url_installer/install_user.sh" > /tmp/install_user.sh;

#    if [ "$dry_run" = false ]; then
        # Change user and begin the install use script
#        sudo -u "$name" bash /tmp/install_user.sh
#    fi
#}

run "$@"
