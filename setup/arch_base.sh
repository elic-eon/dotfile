# partition disk

ask() {
  # http://djm.me/ask
  while true; do

    if [ "${2:-}" = "Y" ]; then
      prompt="Y/n"
      default=Y
    elif [ "${2:-}" = "N" ]; then
      prompt="y/N"
      default=N
    else
      prompt="y/n"
      default=
    fi

    # ask the question
    read -p "$1 [$prompt] " REPLY

    # default?
    if [ -z "$REPLY" ]; then
       REPLY=$default
    fi

    # check if the reply is valid
    case "$REPLY" in
      Y*|y*) return 0 ;;
      N*|n*) return 1 ;;
    esac

  done
}

base() {
    sgdisk -n 128:0:+2M -c 128:"BIOS boot partion" -t 128:ef02 /dev/sda
    sgdisk -n 1:0:+300M -c 1:"/boot" -t 1:ef00 /dev/sda
    sgdisk -n 2:0:+1G -c 2:"Linux swap" -t 2:8200 /dev/sda
    sgdisk -n 3:0:+15G -c 3:"root" -t 3:8300 /dev/sda
    sgdisk -n 4:0:0 -c 3:"home" -t 3:8300 /dev/sda

    # sda        8:0    0   20G  0 disk 
    # ├─sda1     8:1    0  200M  0 part 
    # ├─sda2     8:2    0    1G  0 part 
    # ├─sda3     8:3    0   15G  0 part 
    # ├─sda4     8:4    0 18.8G  0 part 
    # └─sda128 259:1    0    2M  0 part 

    mkswap /dev/sda2
    swapon /dev/sda2
    mkfs.fat -F32 /dev/sda1
    mkfs.ext4 /dev/sda3
    mkfs.xfs /dev/sda3
    mount -t ext4 /dev/sda3 /mnt
    mkdir /mnt/boot && mount /dev/sda1 /mnt/boot
    mkdir /mnt/home && mount /dev/sda1 /mnt/home

    sed -i '1s#^#Server = http://archlinux.cs.nctu.edu.tw/$repo/os/$arch\n#' \
        /etc/pacman.d/mirrorlist

    pacstrap /mnt base base-devel git vim
    genfstab -Up /mnt | tee /mnt/etc/fstab
}

base_2() {
    echo "arch" > /etc/hostname
    echo "127.0.0.1 arch.domain arch" >> /etc/hosts

    ln -s /usr/share/zoneinfo/Asia/Taipei /etc/localtime
    hwclock --systohc --utc --adjfile /etc/adjtime
    timedatectl set-ntp true
    systemctl enable systemd-timesyncd

    echo "KEYMAP=us" > /etc/vconsole.conf
    sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    sed -i 's/^#en_US ISO-8859-1/en_US ISO-8859-1/' /etc/locale.gen
    sed -i 's/^#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
    sed -i 's/^#zh_CN GB2312/zh_CN GB2312/' /etc/locale.gen
    sed -i 's/^#zh_TW.UTF-8 UTF-8/zh_TW.UTF-8 UTF-8/' /etc/locale.gen
    sed -i 's/^#zh_TW BIG5/zh_TW BIG5/' /etc/locale.gen
    locale-gen
    echo LANG=en_US.UTF-8 > /etc/locale.conf

    IF=ens33
    sed -e 's/eth0/$IF/' /etc/netctl/examples/ethernet-dhcp  > /etc/netctl/dhcp
    netctl enable dhcp

    pacman --noconfirm -S openssh zsh sudo
    systemctl enable sshd.service

    vim /etc/mkinitcpio.conf
    # COMPRESSION="cat"
    mkinitcpio -P

    passwd
    useradd -m -g users -G wheel -s /bin/zsh ssuyi
    passwd ssuyi

    visudo

    bootctl install
    cp file/loader/entries/arch.conf /boot/loader/entries/arch.conf
    cp file/loader/loader.conf /boot/loader/loader.conf
}

post() {
    /bin/bash ./pacaur_install.sh

    echo "Configure pacaur..."
    vim /etc/xdg/pacaur/config

    echo "Installing infinality bundle + miffe repo keys..."
    pacman-key --recv-keys 313F5ABD 962DDE58
    pacman-key --lsign-key 313F5ABD 962DDE58

    echo "Installing pacman.conf..."
    cp file/pacman.conf /etc/pacman.conf

    echo "Check pacman.conf..." 
    vim /etc/pacman.conf

    echo "Sync package-database and update..."
    pacaur -Syyu
}

ask "base" Y && base

ask "base_2" Y && base_2

ask "post" Y && post
