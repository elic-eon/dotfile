#!/bin/sh

#------------------------------------------------
# merge in defaults and keymaps
#------------------------------------------------

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*. ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

#------------------------------------------------
# x session settings
#------------------------------------------------

#x cursor
xsetroot -cursor_name left_ptr &
#no bell
xset b off
#typematic delay/ rate
xset r rate 200 30

#gnome-keyring
#eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
#export SSH_AUTH_SOCK
#for uniform qt theme and icons
#export QT_QPA_PLATFORMTHEME="qt5ct"
export BROWSER="/bin/google-chrome-stable"

#------------------------------------------------
# autostart programs + scripts
#------------------------------------------------
export XIM=hime
export XIM_PROGRAM=/usr/bin/hime
export XIM_ARGS=
export XMODIFIERS="@im=hime"
export GTK_IM_MODULE=hime
export QT_IM_MODULE=hime
export QT4_IM_MODULE=hime
export QT5_IM_MODULE=hime
hime &

#/usr/lib/at-spi2-core/at-spi-bus-launcher --launch-immediately &
#gsettings-data-convert &
start-pulseaudio-x11 &
#xdg-user-dirs-gtk-update &
#/usr/lib/lxpolkit/lxpolkit &
#/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
feh --bg-fill ~/.config/default.jpg &
#setroot -fw ~/dotfiles/resources/blue-ridge-mountain.jpg &
#wallch &
compton -b --config ~/.config/compton.conf &
#lightsOn 120 &
#redshift &
#xbacklight -set 75 &
(sleep 3s && clipit -dn) &
(sleep 10s && unclutter -b --timeout 30) &
(sleep 2s && dunst) &
#(sleep 10s && batnotify) &
#rofi -key-run Super_L+a -quiet &
#system-config-printer-applet &
#blueman-applet &
#chromium --no-startup-window &
#caja --no-default-window --no-desktop &
#qutebrowser --nowindow &

#------------------------------------------------
# start WM/DE

exec i3

#i3-shmlog exec i3-with-shmlog 
#i3log exec i3 -V >> ~/.i3log-$(date +'%F-%k-%M-%S') 2>&1  

