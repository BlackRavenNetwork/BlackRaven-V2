
Debian
====================
This directory contains files used to package blackravend/blackraven-qt
for Debian-based Linux systems. If you compile blackravend/blackraven-qt yourself, there are some useful files here.

## blackraven: URI support ##


blackraven-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install blackraven-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your blackraven-qt binary to `/usr/bin`
and the `../../share/pixmaps/blackraven128.png` to `/usr/share/pixmaps`

blackraven-qt.protocol (KDE)

