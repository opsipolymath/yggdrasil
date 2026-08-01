#!/bin/bash

if mountpoint -q /mnt; then
	printf 'ERROR: Something is already mounted to /mnt\n' >&2
	printf '       Try # umount -R /mnt\n' >&2
	exit
fi

if [[ -z "$EFI_DEVICE" ]]; then
	printf 'ERROR: Environment variable $EFI_DEVICE not set\n' >&2
	printf '       Example: # export EFI_DEVICE=/dev/nvme0n1p1\n' >&2
	exit
fi
if [[ ! -b "$EFI_DEVICE" ]]; then
	printf 'ERROR: Environment variable $EFI_DEVICE not a block device\n' >&2
	exit
fi
_esp_guid='c12a7328-f81f-11d2-ba4b-00a0c93ec93b'
if ! read -r type parttype < <(
	lsblk --nodeps --noheadings --raw --output TYPE,PARTTYPE "$EFI_DEVICE" 2>/dev/null
	) || [[ $type != part || ${parttype,,} != "$_esp_guid" ]]; then
	printf 'ERROR: %s not an EFI System Partition\n' "$EFI_DEVICE" >&2
	exit
fi

if [[ -z "$ROOT_DEVICE" ]]; then
	printf 'ERROR: Environment variable $ROOT_DEVICE not set\n' >&2
	printf '       Example: # export ROOT_DEVICE=/dev/nvme0n1p3\n' >&2
	exit
fi
if [[ ! -b "$ROOT_DEVICE" ]]; then
	printf 'ERROR: Environment variable $ROOT_DEVICE not a block device\n' >&2
	exit
fi

if [[ -z "$PKG_LIST" ]]; then
	printf 'ERROR: Environemnt variable $PKG_LIST must include at leat one package\n' >&2
	printf "       Exmaple: # export PKG_LIST='yggdrasil-pkg1 yggdrasil-pkg2'\n" >&2
	exit
fi

mkfs.fat -F 32 -n EFI "$EFI_DEVICE" || {
	printf 'ERROR: Failed formatting ESP\n' >&2
	exit
}
mkfs.btrfs -fL root "$ROOT_DEVICE" || {
	printf 'ERROR: Failed formatting root\n' >&2
	exit
}

mount /dev/nvme0n1p3 /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@root_snapshots
btrfs subvolume create /mnt/@home_snapshots
btrfs subvolume create /mnt/@containers
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@archbuild
btrfs subvolume create /mnt/@aurbuild
btrfs subvolume create /mnt/@containerd
btrfs subvolume create /mnt/@docker
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@tmp

umount /mnt

mount -o compress=zstd:1,noatime,subvol=@                /dev/nvme0n1p3  /mnt
mkdir /mnt/{.snapshots,home}
mount -o compress=zstd:1,noatime,subvol=@home            /dev/nvme0n1p3  /mnt/home
mkdir /mnt/home/.snapshots

mkdir -p /mnt/{boot,mnt/btrfs_root,containers,var/{cache,lib/{archbuild,aurbuild,containerd,docker},log,tmp}}

mount /dev/nvme0n1p1 /mnt/boot
mount /dev/nvme0n1p3 /mnt/mnt/btrfs_root

mount -o compress=zstd:1,noatime,subvol=@root_snapshots  /dev/nvme0n1p3  /mnt/.snapshots
mount -o compress=zstd:1,noatime,subvol=@home_snapshots  /dev/nvme0n1p3  /mnt/home/.snapshots
mount -o compress=zstd:1,noatime,subvol=@containers      /dev/nvme0n1p3  /mnt/containers
mount -o compress=zstd:1,noatime,subvol=@cache           /dev/nvme0n1p3  /mnt/var/cache
mount -o compress=zstd:1,noatime,subvol=@archbuild       /dev/nvme0n1p3  /mnt/var/lib/archbuild
mount -o compress=zstd:1,noatime,subvol=@aurbuild        /dev/nvme0n1p3  /mnt/var/lib/aurbuild
mount -o compress=zstd:1,noatime,subvol=@containerd      /dev/nvme0n1p3  /mnt/var/lib/containerd
mount -o compress=zstd:1,noatime,subvol=@docker          /dev/nvme0n1p3  /mnt/var/lib/docker
mount -o compress=zstd:1,noatime,subvol=@log             /dev/nvme0n1p3  /mnt/var/log
mount -o compress=zstd:1,noatime,subvol=@tmp             /dev/nvme0n1p3  /mnt/var/tmp

pacstrap -K /mnt $PKG_LIST

genfstab -U /mnt |
	awk -v OFS='\t' '
		BEGIN {
			remove["ssd"] = 1
			remove["discard=async"] = 1
			remove["space_cache=v2"] = 1
			remove["codepage=437"] = 1
			remove["iocharset=ascii"] = 1
			remove["shortname=mixed"] = 1
			remove["utf8"] = 1
			remove["errors=remount-ro"] = 1
		}

		/^[[:space:]]*#/ { next }
		/^[[:space:]]*$/ { next }

		{
			count = split($4, option, ",")
			output = ""

			for (i = 1; i <= count; i++) {
				value = option[i]

				if (value == "rw")
					value = "defaults"
				else if (value == "fmask=0022")
					value = "fmask=0177"
				else if (value == "dmask=0022")
					value = "dmask=0077"
				else if (value in remove)
					continue

				output = output (output == "" ? "" : ",") value
			}

			$4 = output
			line = $0

			if ($2 == "/")
				root = line
			else if ($2 == "/boot")
				boot = line
			else if ($2 == "/.snapshots" )
				root_snaps = line
			else if ($2 == "/home/.snapshots")
				home_snaps = line
			else if ($2 == "/mnt/btrfs_root")
				btrfs_root = line
			else
				other[++other_count] = line
		}

		END {
			if (root != "")
				print root

			if (boot != "")
				print boot

			for (i = 1; i <= other_count; i++)
				print other[i]

			if (root_snaps != "")
				print root_snaps

			if (home_snaps != "")
				print home_snaps

			if (btrfs_root != "")
				print btrfs_root
		}
	' | column --table --separator $'\t' --output-separator '  ' >> /mnt/etc/fstab
