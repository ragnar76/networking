#!/usr/bin/env bash

function check_requirements () {

# Prüfen ob die verwendete Distro ein Ubuntu ist
	DISTRO=$(grep -e "^NAME=\"" /etc/os-release | awk -F \" '{print $2}')
	if [ ! "${DISTRO}" = "Ubuntu" ]; then
		echo "Kein Ubuntu -> Abbruch!"
#	 	exit 1
	fi	

# Prüfen ob erforderliche Rechte vorliegen
	if [ "$EUID" -ne 0 ]; then
		echo "Das Script bitte als Root ausführen! -> Abbruch"
# 		exit 1
	fi

# prüfen ob die benötigten Pakete installiert sind
	packages=("ifupdown" "net-tools" "dnsmasq" "iptables-persistent")

	for pkg in ${packages[@]}; do

	    is_pkg_installed=$(dpkg-query -W --showformat='${Status}\n' ${pkg} | grep "install ok installed")

	    if [ ! "${is_pkg_installed}" == "install ok installed" ]; then
	        echo "${pkg} ist nicht installiert -> Abbruch"
#	        exit 1
	    fi
	done
}

function print_interfaces() {

# rausfinden welche Netzwerkgeräte es gibt und in ein array schreiben
	# Debug: Textdatei einlesen die Fake-Devices enthält
	NETDEV=$(cat fake-devs.txt | awk -F " " '{print $2}' | grep -e "enp\|ens\|enx\|eth" | sort)

	# the real shit
	# NETDEV=$(ip -br -c link show | awk -F " " '{print $1}' | grep -e "enp\|ens\|enx\|eth" | sort)
	readarray -t devs <<<"${NETDEV}"

	echo "Es sind "${#devs[@]}" Netzwerkgeräte verfügbar!"

# prüfen ob es mindesten 3 (oder mehr) Netzwerkgeräte gibt
	if [[ ! "${#devs[@]}" -ge "3" ]]; then
		if [[ "${#devs[@]}" -lt "2" ]]; then
			echo "Es ist nur "${#devs[@]}" Netzwerkgerät vorhanden! -> Abbruch"
#			exit 1
		else
			echo "Es sind nur ${#devs[@]} Netzwerkgeräte vorhanden! -> Abbruch"
#			exit 1
		fi
	else

# alles was zwischen END_OF_INTERFACES steht in die Datei
# /etc/network/interfaces schreiben. Das ist die statische
# Netzwerkkonfiguration für die ersten drei Netzwerk-
# geräte. Alle anderen, so vorhanden, werden hier in diesem
# script ignoriert!
cat << END_OF_INTERFACES
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

function print_resolver() {
	if [ -f /etc/resolv.conf ]; then
# 		mv /etc/resolv.conf /etc/resolv.conf.dist
		echo -e "nameserver 1.1.1.1\nnameserver 8.8.8.8"
	else
		echo "Aus irgendeinem Grund gibt es /etc/resolv.conf nicht.\n\nI make a new one"
		echo -e "nameserver 1.1.1.1\nnameserver 8.8.8.8"
	fi
}

check_requirements
print_interfaces
print_resolver
# print_iptables
# print_dnsmasq_config
