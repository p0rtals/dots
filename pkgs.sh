#!/bin/bash

pacaur -S xorg-server \
          xorg-apps \
          xorg-xinit \
          i3-gaps \
          i3lock-fancy-git \
          i3blocks-gaps-git \
          polybar-git \
          dmenu \
          rofi \
          rofi-dmenu \
          feh \
          neofetch \
          termite \
          firefox \
          thunar \
          thunar-volman \
          compton \
          dunst \
          atom \
          zsh-grml-config \
          zsh-syntax-highlighting \
          conky \
          pulseaudio \
          pulseaudio-alsa \
          alsa-plugins \
          alsa-utils \
          pavucontrol \
          pulseaudio-ctl \
          python2 \
          python \
          python-pip \
          python-pywal \
          p7zip \
          unzip \
          rar \
          zip \
          docker \
          docker-compose \
          w3m \
          lxappearance \
          rsync \
          skippy-xd --noedit --noconfirm \

# Install nvm
&& wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.5/install.sh | bash
