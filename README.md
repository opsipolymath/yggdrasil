# yggdrasil
yggdrasil is a set of proof-of-concept packages for Arch Linux deigned to test and demonstrate the power of the Arch Build System. The goal is to exemplify a pseudo-reproducible build of a group of operating systems forming a complete homelab infrastructure by utilizing custom packages/metapackages with connected dependencies to be able to install an entire operating system, including all configuration files, by passing a single package to the Arch Linux `pacstrap` utility during installation.

**THESE PACKAGES MAY NOT FOLLOW BEST PRACTICES OR RESPECT PACKAGING GUIDELINES AS THEY ARE FOR PERSONAL AND INFORMATIONAL PURPOSES ONLY**

## Licensing/Warranty
This entire repo is licensed under GPLv3. It is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Everything in this repo is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

A copy of the [GNU General Public License v3](LICENSE) is included with this repo.

## Requisite Knowledge
This project is not designed to be an automated installer for new users. The opposite, in fact. This project is meant for experienced users looking for an alternative that can be easily adapted as their hardware and situation changes. Or rather, it serves as proof that such a thing can exist, using only one method out of many that can be used to implement it. To what degree it suits an individual's needs will require extensive knowledge to assess. Necessary topics include, but are not limited to the Linux command line and common GNU utilities, bash scripting, and the Arch Linux Build System including writing/maintaining PKGBUILD files, using `pacman` and `makepkg`, and creating/updating a local repository.

This is a highly customized project. **Files in this repository should not be used in their current state without confirming that they do not require modification to suit your environment.**

As a custom, standalone project for advanced users, attempting to adapt anything here for your own project will be unsupported by any and all official Arch Linux support fora.

## Roles/Hardware
The following determinations were made to simulate what appears to be commonly used applications in a homelab environment, and hardware selected based on what is readily available:
* Remote Servers:
	* Testbed | niflheim
		* Hardware: VPS
		* Roles:
			* A simple testbed for reviewing/testing software or build ideas
	* Repository Server | vanaheim
		* Hardware: Remote VPS (vultr or other, maybe even github pages)
		* Roles:
			* Webserver/WKD/personal repo
* Home Servers:
	* Network Gateway | himinbjorg
		* Hardware: Headless Intel NUC
		* Roles:
			* Firewall
			* Encrypted DNS with caching ad-blocking
			* DHCP server
			* Encrypted reverse proxy
			* VPN server
			* Public key infrastructure host for use with Let's Encrypt
			* Certificate management
	* File Server | valhalla
		* Hardware: Headless Epyc-based Server with IPMI
		* Roles:
			* ZFS storage pool host
			* Samba server
			* WebDAV server
			* Other services as required
* Workstations:
	* Desktop | bilskirnir
		* Hardware: Intel-based desktop with 2 Nvidia GPUs
		* Roles:
			* 2D/3D acceleration
			* GPU passhtrough to VM
			* bspwm or hyprland with basic application set
			* Simple gaming with Steam
	* Laptop | midgard
		* Hardware: Lenovo Carbon X1
		* Roles:
			* 2D/3D acceleration
			* Hybrid graphics
			* bspwm or hyprland with basic application set
			* Simple gaming with Steam

## Packages/Metapackages
The whole concept behind this project is to create packages and metapackages and use dependencies to ensure the entire operating system is installed. As the goal is to include all setup and configuration steps as well, many custom scripts and config files are included as well. A brief summary of the packages follows:
* `yggdrasil-base`: A base set of packages for yggdrasil-based packages
	* `yggdrasil-cpu`: CPU microcode for yggdrasil-based packages
	* `yggdrasil-gpu`: GPU drivers and related packages for yggdrasil-based packages
	* `yggdrasil-server`: A set of packages common to all yggdrasil-based servers
		* `yggdrasil-niflheim`: The set of packages required for niflheim (testbed)
		* `yggdrasil-vanaheim`: The set of packages required for vanaheim (webserver)
		* `yggdrasil-himinbjorg`: The set of packages required for himinbjorg (gateway)
		* `yggrrasil-valhalla`: The set of packages required for valhalla (file server)
	* `yggdrasil-workstation`: A set of packages common to all yggdrasil-based workstations
		* `yggdrasil-bilskirnir`: The set of packages required for bilskirnir (desktop)
		* `yggdrasil-midgard`: The set of packages required for midgard (laptop)

## Deployment
Packages will be built and deployed as they are ready. Built copies can be found in the `packages` directory, as well as any dependencies that can't be found in the official repositories.

## Task List
- [*] Create repo, select license, create README.md
- [*] Create prototpes
- [*] Create -base package
- [*] Create -admin package
- [ ] Create -cpu packages
- [ ] Create -boot packages
- [ ] Create -server packages
- [ ] Create -networking packages
- [ ] Create -snapper package
- [ ] Create -gpu packages
- [ ] Create -workstation packages
- [ ] Write simple installer script
