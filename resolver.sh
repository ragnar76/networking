#!/usr/bin/env bash

if [ -f /etc/resolv.confx ]; then
# 		mv /etc/resolv.conf /etc/resolv.conf.dist
	echo -e "nameserver 1.1.1.1\nnameserver 8.8.8.8"
else
	echo -e "Aus irgendeinem Grund gibt es /etc/resolv.conf nicht!\n\nI make a new one"
	echo -e "nameserver 1.1.1.1\nnameserver 8.8.8.8"
fi
