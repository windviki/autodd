#!/bin/sh
set -x
# file lock to avoid other rc_firewall running at the same time
#LOCK='/tmp/rc_fw_done'

#if [ -e $LOCK ]; then
#	echo "[DEBUG] other rc_firewall may already be running, quit" >> $VPNLOG
#	exit 1
#else
#	touch $LOCK
#fi

#VPNUP='vpnup-dev.sh'
VPNUP='vpnup.sh'
VPNDOWN='vpndown.sh'
VPNLOG='/tmp/autoddvpn.log'
PPTPSRVSUB=$(nvram get pptpd_client_srvsub)
DLDIR='http://autoddvpn.googlecode.com/svn/trunk/'
PID=$$
INFO="[INFO#${PID}]"
DEBUG="[DEBUG#${PID}]"

#
# By running this script, we'll assign the following variables into nvram 
#
# pptpd_client_dev : the device name of pptp client, eg. ppp0 ppp1 ...
# pptp_gw : the gateway IP of the PPTP VPN
#

#ping -W 3 -c 1 $VPNIP > /dev/null 2>&1 
date
#while true
for i in 1 2 3 4 5
do
	if [ $PPTPSRVSUB != '' ]; then
		# pptp is up
		PPTPDEV=$(route | grep ^$PPTPSRVSUB | awk '{print $NF}')
		if [ $PPTPDEV != '' ]; then
			#echo "$INFO got PPTPDEV as $PPTPDEV, set into nvram" >> $VPNLOG
			echo "$INFO got PPTPDEV as $PPTPDEV, set into nvram"
			nvram set pptpd_client_dev="$PPTPDEV"
		else
			echo "$DEBUG failed to get PPTPDEV, retry in 3 seconds"
			sleep 3
			continue
		fi

		# find the PPTP gw
		#while true
		for i in 1 2 3
		do
			PPTPGW=$(ifconfig $PPTPDEV | grep -Eo "P-t-P:([0-9.]+)" | cut -d: -f2)
			if [ $PPTPGW != '' ]; then
				echo "$INFO got PPTPGW as $PPTPGW, set into nvram"
				nvram set pptp_gw="$PPTPGW"
				break
			else
				echo "$DEBUG failed to get PPTPGW, retry in 3 seconds"
				sleep 3
				continue
				# let it fall into endless loop if we still can't find the PPTP gw
			fi
		done
		
		# PPTPGW is good, let's check the default GW
		#GW=$(route | grep ^def | head -n1 | awk '{print $2}' )
		GWDEV=$(route | grep ^def | head -n1 | awk '{print $NF}')

		#echo "$DEBUG my current gw is $GW"
		echo "$DEBUG my current GWDEV is $GWDEV"
		#if [ "${GW}X" != "$(nvram get pptp_gw)X" ]; then
		if [ "${GWDEV}X" != "$(nvram get pptpd_client_dev)X" ]; then
			#echo "current default GW is not $(nvram get pptp_gw)"
			echo "current default GWDEV is not $(nvram get pptpd_client_dev)"
			echo "rebuild the routing tables now"
			cd /tmp; 
			test -f $VPNDOWN && /bin/sh $VPNDOWN 2>&1
			test -f $VPNUP && /bin/sh $VPNUP 2>&1
			#rm -f $VPNUP
			##( /usr/bin/wget $DLDIR$VPNUP -O - | /bin/sh  2>&1 ) >> $VPNLOG
			#( /usr/bin/wget $DLDIR$VPNUP && /bin/sh $VPNUP 2>&1 ) >> $VPNLOG
		else                                                              
			# try to fix bug                                          
			ping -c 3 $(nvram get pptp_gw) > /dev/null && \           
			ping -c 3 8.8.8.8 || \                                    
			( echo "pptp_gw is good but can't approach 8.8.8.8";     
			echo "we probably hit a known but, reboot the router now."  
         reboot;  exit; )                                               
                                                                                      
			echo "everything is GOOD, let's go back to sleep"
			break
		fi
		
		# now we hve the PPTPGW, let's modify the routing table
		#echo "$INFO VPN is UP, trying to modify the routing table" >> $VPNLOG
		#cd /tmp; 
		#rm -f $VPNUP
		##( /usr/bin/wget $DLDIR$VPNUP -O - | /bin/sh  2>&1 ) >> $VPNLOG
		#( /usr/bin/wget $DLDIR$VPNUP && /bin/sh $VPNUP 2>&1 ) >> $VPNLOG
		#rt=$?
		#echo "$DEBUG return $rt" >> $VPNLOG
		#if [ $rt -eq 0 ]; then 
		#	echo "$DEBUG break" >> $VPNLOG
		#	break; 
		#fi
	else
		echo "$INFO VPN is down, please bring up the PPTP VPN first."
		sleep 3
	fi
done

#rm -f $LOCK
