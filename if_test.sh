#!/usr/bin/env bash

if [[ -f /etc/resolv.conf ]]; then
	echo "Datei gibbet!"
else
	echo "Datei gibbet nich!"
fi
