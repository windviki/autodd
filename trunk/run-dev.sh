#!/bin/sh

# file lock to avoid other rc_firewall running at the same time
LOCK='/tmp/rc_fw_done'

#if [ -e $LOCK ]; then
#	echo "[DEBUG] other rc_firewall may already be running, quit" >> $VPNLOG
#	exit 1
#else
#	touch $LOCK
#fi

VPNUP='vpnup.sh'
VPNDOWN='vpndown.sh'
VPNLOG='/tmp/autoddvpn.log'
PPTPSRVSUB=$(nvram get pptpd_client_srvsub)
DLDIR='http://autoddvpn.googlecode.com/svn/trunk/'
CRONJOBS="* * * * * root /bin/sh /tmp/check.sh >> /tmp/last_check.log"
PID=$$
INFO="[INFO#${PID}]"
DEBUG="[DEBUG#${PID}]"
IPUP="/tmp/pptpd_client/ip-up"
IPDOWN="/tmp/pptpd_client/ip-down"


#
# By running this script, we'll assign the following variables into nvram 
#
# pptpd_client_dev : the device name of pptp client, eg. ppp0 ppp1 ...
# pptp_gw : the gateway IP of the PPTP VPN
#

#ping -W 3 -c 1 $VPNIP > /dev/null 2>&1 

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") log starts" >> $VPNLOG

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") fetch vpnup.sh" >> $VPNLOG
/usr/bin/wget $DLDIR$VPNUP 2>&1 
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") fetch vpndown.sh" >> $VPNLOG
/usr/bin/wget $DLDIR$VPNDOWN 2>&1
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") fetch check.sh" >> $VPNLOG
/usr/bin/wget "${DLDIR}/cron/check.sh"


echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") modifying $IPUP" >> $VPNLOG

ls -al /tmp/pptpd_client/ >> $VPNLOG
ls /tmp/pptpd_client >> $VPNLOG
for i in 1 2 3 4 5 6 7 8 9 10 11 12
do
	if [ -e $IPUP ]; then
		#tail -n 5 $IPUP >> $VPNLOG
		sed -ie 's#exit 0#/bin/sh /tmp/vpnup.sh\nexit 0#g' $IPUP
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") $IPUP modified" >> $VPNLOG
		break
	else
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") $IPUP not exists, sleep 10sec." >> $VPNLOG
		sleep 10
	fi
done

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") modifying $IPDOWN" >> $VPNLOG
if [ -e $IPDOWN ]; then
	#tail -n 5 $IPDOWN >> $VPNLOG
	sed -ie 's#exit 0#/bin/sh /tmp/vpndown.sh\nexit 0#g' $IPDOWN
	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") $IPDOWN modified" >> $VPNLOG
else
	echo "$IPDOWN not exists" >> $VPNLOG
fi
	
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") ALL DONE. Let's wait for VPN being connected." >> $VPNLOG


