#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

###START###
echo ""
echo "If you didn't plug pour wireless usb adapter, do it now."
echo "You're about to turn yoiu rpi insto a wifi access point."
echo ""
echo "Are you ready? (yes/no)"
echo ""

read -r answer

#If yes then let's go
if [[ "$answer" = "y" ]]
then
	#Performing system upgrade
	echo "Upgrading system"
	echo ""
	apt update
	apt -y dist-upgrade

	#Setting network for wlan0
	echo "Configuring dhcpd"
	echo "interface wlan0" >> /etc/dhcpcd.conf
	echo "static ip_address=192.168.200.254/24" >> /etc/dhcpcd.conf
	echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf
	echo "nohook wpa_supplicant" >> /etc/dhcpcd.conf

	echo "Reloading dhcpd config"
	systemctl restart dhcpd
	if [[ $(systemctl is-active dhcpd) != "active" ]]
		then
			echo "Something went wrong during dhcpd config."
			echo "Please check /etc/dhcpd.conf"
			exit 1
		fi

	#Installing hostpad and dnsmasq
	apt -y install hostapd dnsmasq

	#Configuring dnsmasq
	echo "interface=wlan0" >> /etc/dsnmasq.conf
	echo "dhcp-range=192.168.200.50,192.168.200.60,255.255.255.0,24h" >> /etc/dsnmasq.conf

	#Configuring hostpad
	#mkdir /etc/hostpad
	cp files/hostpad.conf /etc/hostpad/

	#Restarting dnsmasq
	systemctl restart dnsmasq
	if [[ $(systemctl is-active dnsmasq) != "active" ]]
		then
			echo "Something went wrong during dnsmasq config."
			echo "Please check /etc/dsnmasq.conf"
			exit 1
		fi

	#Restarting hostpad
	systemctl restart hostpad
	if [[ $(systemctl is-active hostpad) != "active" ]]
		then
			echo "Something went wrong during dhcpd config."
			echo "Please check /etc/hostpad/hostpad.conf"
			exit 1
		fi

#Bad answer to the question
else	
	echo "Please answer either 'yes' or no'"
	exit 0
fi

###END###