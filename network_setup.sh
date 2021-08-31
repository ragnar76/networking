#!/usr/bin/env bash

# NetworkModify.sh
#
# modifiziert das Netzwerk an einem Ubuntu 20.x System.
#
# LAN1 ist das eingehende Interface und LAN2 sowie LAN3 sind die internen Netz-
# werke die per NAT an das Internet angebunden werden.
#
# Das Script _muss_ mir Rootrechten oder mit "sudo" gestartet werden
#
# Bernd Müller (ESAG) für Payfree 

# benötigte Pakete
PACKAGES=(ifupdown net-tools dnsmasq iptables-persistent)

# #############################################################################
# Beginn der Funktionen                                                       #
###############################################################################

function print_interfaces() {

	# rausfinden welche Netzwerkgeräte es gibt und in ein array schreiben
	NETDEV=$(ip -br -c link show | awk -F " " '{print $1}' | grep -e "enp\|eth" | sort)
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


# #############################################################################
# Ende der Funktionen                                                         #
###############################################################################


# Prüfen ob erforderliche Rechte vorliegen
if [ "$EUID" -ne 0 ]
  then echo "Das Script bitte als Root ausführen!"
  exit 1
fi

# Prüfen ob die verwendete Distro ein Ubuntu ist
DISTRO=$(grep -e "^NAME=\"" /etc/os-release | awk -F \" '{print $2}')
if [ ! "${DISTRO}" = "Ubuntu" ]; then
	echo "Kein Ubuntu -> Abbruch!"
 	# exit 1
fi

# Network-manager abschalten
#sudo systemctl stop NetworkManager.service
#sudo systemctl disable NetworkManager.service

#sudo ssytemctl stop NetworkManager-wait-online.service
#sudo systemctl disable NetworkManager-wait-online.service

#sudo systemctl stop NetworkManager-dispatcher.service
#sudo systemctl disable NetworkManager-dispatcher.service

#sudo systemctl stop network-manager.service
#sudo systemctl disable network-manager.service

# Die Datei /etc/network/interfaces erstellen und eine vorhandene ggf. sichern
if [ -f /etc/network/interfaces ]; then
	echo "Datei vorhanden"
	# mv /etc/network/interfaces /etc/network/interfaces.dist
	print_interfaces()
else
	echo "Datei nicht vorhanden -> Abbruch"
	exit 1
fi

# Die Datei /etc/resolv.conf erstellen und eine vorhandene ggf. sichern
if [ -f /etc/resolv.conf ]; then
	echo "Datei vorhanden"
	# mv /etc/resolv.conf /etc/resolv.conf.dist
	# echo -e "nameserver 1.1.1.1\nnameserver 8.8.8.8" > /etc/resolv.conf
else
	echo "Datei nicht vorhanden -> Abbruch"
	exit 1
fi

# Die Datei /etc/iptables.d/ipv4 erstellen und eine vorhandene ggf. sichern
if [ -f /etc/iptables.d/ipv4 ]; then
	echo "Datei vorhanden"
	# mv /etc/iptables.d/ipv4 /etc/iptables.d/ipv4.dist
	write_iptables()
else
	echo "Datei nicht vorhanden -> Abbruch"
	exit 1
fi