#!/bin/sh

# file lock to avoid other rc_firewall running at the same time
LOCK='/tmp/rc_fw_done'
if [ -e $LOCK ]; then
	echo "[DEBUG] other rc_firewall may already be running, quit" | tee -a $VPNLOG
	exit 1
else
	touch $LOCK
fi

VPNUP='vpnup.sh'
VPNLOG='/tmp/autoddvpn.log'
PPTPSRVSUB=$(nvram get pptpd_client_srvsub)
DLDIR='http://autoddvpn.googlecode.com/files/'

#
# By running this script, we'll assign the following variables into nvram 
#
# pptpd_client_dev : the device name of pptp client, eg. ppp0 ppp1 ...
# pptp_gw : the gateway IP of the PPTP VPN
#

#ping -W 3 -c 1 $VPNIP > /dev/null 2>&1 

while true
do
	if [ $PPTPSRVSUB != '' ]; then
		# pptp is up
		PPTPDEV=$(route | grep ^$PPTPSRVSUB | awk '{print $NF}')
		if [ $PPTPDEV != '' ]; then
			echo "[INFO] got PPTPDEV as $PPTPDEV, set into nvram" | tee -a $VPNLOG
			nvram set pptpd_client_dev="$PPTPDEV"
		else
			echo "[DEBUG] failed to get PPTPDEV, retry in 3 seconds" | tee -a $VPNLOG
			sleep 3
			continue
		fi

		# find the PPTP gw
		while true
		do
			PPTPGW=$(ifconfig $PPTPDEV | grep -Eo "P-t-P:([0-9.]+) " | cut -d: -f2)
			if [ $PPTPGW != '' ]; then
				echo "[INFO] got PPTPGW as $PPTPGW, set into nvram" | tee -a $VPNLOG
				nvram set pptp_gw="$PPTPGW"
				break
			else
				echo "[DEBUG] failed to get PPTPGW, retry now" | tee -a $VPNLOG
				sleep 3
				continue
				# let it fall into endless loop if we still can't find the PPTP gw
			fi
		done
		
		# now we hve the PPTPGW, let's modify the routing table
		echo "[INFO] VPN is UP, trying to modify the routing table" | tee -a $VPNLOG
		cd /tmp; 
		rm -f $VPNUP
		( /usr/bin/wget $DLDIR$VPNUP -O - | /bin/sh  2>&1 ) | tee -a $VPNLOG
		rt=$?
		echo "[DEBUG] return $rt" | tee -a $VPNLOG
		if [ $rt -eq 0 ]; then 
			#echo "[INFO] fix dnsmasq from DNS hijacking"  | tee -a $VPNLOG
			#( /usr/bin/wget http://pahud.net/@ddwrt/dnsmasq-fix.sh -O - | /bin/sh 2>&1 ) | tee -a $VPNLOG
			echo "[DEBUG] break" | tee -a $VPNLOG
			break; 
		fi
	else
		echo "[INFO] VPN is down, please bring up the PPTP VPN first." | tee -a $VPNLOG
		sleep 10
	fi
done

rm -f $LOCK
