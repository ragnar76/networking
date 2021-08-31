#!/usr/bin/env bash

function print_interfaces() {

	# rausfinden welche Netzwerkgeräte es gibt und in ein array schreiben
	NETDEV=$(ip -br -c link show | awk -F " " '{print $1}' | grep -e "enp\|ens\|enx\|eth" | sort)
	readarray -t devs <<<"${NETDEV}"

	if [[ ! "${#devs[@]}" -ge "1" ]]; then
		echo "nope"
		exit 1
	else

cat << END_OF_INTERFACES > /tmp/test_file.out
source /etc/network/interfaces.d/*

auto lo
	iface lo inet loopback

auto ${devs[0]}
allow-hotplug ${devs[0]}
	iface ${devs[0]} inet dhcp

auto ${devs[1]}
allow-hotplug ${devs[1]}
    iface ${devs[1]} inet static
	address 192.168.3.1
	netmask 255.255.255.0

auto ${devs[2]}
allow-hotplug ${devs[2]}
    iface ${devs[2]} inet static
	address 192.168.4.1
	netmask 255.255.255.0
END_OF_INTERFACES
	fi
}

print_interfaces
