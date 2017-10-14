#!/bin/sh
rootpass=root
user=vio
userpass=root
hostname=p0rtal

# Backup and Replace Makepkg.conf
mv /etc/makepkg.conf{,.orig} \
&& mv /etc/pacman.conf{,.orig} \
&& mv /etc/pacman.d/mirrorlist{,.orig} \
&& cp -r /tmp/dots/etc/* /etc/

# Update pacman
pacman -Syyu --noconfirm

# Setup EFI bootloader
cp -r /tmp/dots/EFI /boot/efi/ \
&& cd /boot/efi \

# Move Kernel to EFI partition
&& find . -type f -exec mv '{}' /boot/efi/EFI/arch/ \;

# Edit refind_linux.conf to add kernel parameters to Arch
refinduuid="root=$(blkid -o export $root | grep PARTUUID)"
sed -i "s/-refinduuid-/$refinduuid/g" /boot/efi/EFI/arch/refind_linux.conf

# setup locale settings
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
ln -sf /usr/share/zoneinfo/America/Denver /etc/localtime
hwclock --systohc
locale-gen

# Hosts and Hostname
echo $hostname >> /etc/hostname

cat > /etc/hosts <<EOF
# <ip-address>	<hostname.domain.org>	<hostname>
127.0.0.1	localhost.localdomain	localhost
::1		    localhost.localdomain	localhost
127.0.1.1	-hostname.localdomain	-hostname
# End of file
EOF

sed -i "s/-hostname/$hostname/g" /etc/hosts

# Enable dhcpcd on boot
systemctl enable dhcpcd

# Edit sudoers for $user
sudo sed -i 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers

# Startx on login
sudo cat >> /etc/profile.d/startx.sh <<EOF
#!/bin/bash
if [[ "$(tty)" == '/dev/tty1' ]]; then
  exec Startx
fi
EOF
# make exec
chmod +x /etc/profile.d/startx.sh

# Add non-root user
useradd -m -G wheel,storage,power,audio,network -s /bin/zsh $user

# Set passwords
echo -e "$rootpass\n$rootpass\n" | passwd root
echo -e "$userpass\n$userpass\n" | passwd $user

# Set up stuff for $user in home directory
mkdir /home/$user/{.build,scripts} \
&& cp -r /tmp/dots/home/$user/* /home/$user/ \
&& cp /tmp/dots/*.sh /home/$user/scripts/ \

# Download pacaur and its dependency cower
git clone https://aur.archlinux.org/cower.git /home/$user/.build/
git clone https://aur.archlinux.org/pacaur.git /home/$user/.build/

# Fix permissions on $user home
chown -R $user:$user /home/$user/*

# Install aur helper as our non-root user
sudo -u $user cd /home/$user/cower \

# Run next command as sudo to avoid the password prompt from makepkg
&& echo $userpass | sudo -S pacman -S expac yajl \

# Make cower with pgp skip
&& makepkg -csi --skippgpcheck --noconfirm \

# Make and install pacaur
&& cd ../pacaur && makepkg -csi --noconfirm \

# Update pacaur
&& pacaur -Syy && cd /home/$user/scripts && ./pkgs.sh

# Set up .xinitrc
echo "#!/bin/bash" >> /home/$user/.xinitrc
echo "exec i3" >> /home/$user/.xinitrc

# Set permissions on exit just to be sure
chown -R $user:$user /home/$user/*

# All done
exit
