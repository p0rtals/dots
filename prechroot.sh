#!/bin/bash

disk=/dev/sdb
efipart=1
rootpart=2
swappart=5
storagepart=4

# Combine
efi=${disk}${efipart}
root=${disk}${diskpart}
swap=${disk}${swappart}
storage=${disk}${storagepart}

# Format Partitions
mkfs.fat -F32 -n EFI /dev/$efi
mkfs.ext4 -L Arch /dev/$root
mkfs.ext4 -L storage /dev/$storage
mkswap -L swap /dev/$swap
swapon /dev/$swap

# Mount partitions
mount /dev/$root /mnt
mkdir -p /mnt/{storage,boot/efi}
mount /dev/$efi /mnt/boot
mount /dev/$storage /mnt/storage

# install zen kernel
pacstrap /mnt linux-zen linux-zen-headers base-devel git zsh sudo vim

# Easy refind ghetto hack
umount -l /dev/$efi \
&& mount /dev/$efi /mnt/boot/efi

genfstab -U /mnt >> /mnt/etc/fstab

cat <<EOF > /mnt/tmp/inchroot.sh
#!/bin/bash
git clone https://github.com/p0rtals/dots.git /tmp/dots \
&& cd /tmp/dots \
&& chmod +x install.sh \
&& chmod +x pkgs.sh \
&& ./install.sh
EOF

chmod +x /mnt/tmp/inchroot.sh

arch-chroot /mnt /tmp/inchroot.sh

efibootmgr --create --disk $disk --part $efipart --loader \\EFI\\refind\\refind_x64.efi --label rEFInd

reboot
