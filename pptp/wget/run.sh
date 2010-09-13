#!/bin/sh

set -x 
VPNUP='vpnup.sh'
VPNDOWN='vpndown.sh'
VPNLOG='/tmp/autoddvpn.log'
#PPTPSRVSUB=$(nvram get pptpd_client_srvsub)
DLDIR='http://autoddvpn.googlecode.com/svn/trunk/'
NCCMD='nc -w 10 autoddvpn.googlecode.com 80'
#CRONJOBS="* * * * * root /bin/sh /tmp/check.sh >> /tmp/last_check.log"
PID=$$
INFO="[INFO#${PID}]"
DEBUG="[DEBUG#${PID}]"
IPUP="/tmp/pptpd_client/ip-up"
IPDOWN="/tmp/pptpd_client/ip-down"


echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") log starts" >> $VPNLOG
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") pptp+wget mode" >> $VPNLOG

cd /tmp
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") getting vpnup.sh" >> $VPNLOG
for i in 1 2 3 4 5
do
	if [ $(which nc) ]; then
		#echo -e "GET $DLDIR$VPNUP HTTP/1.0\n\n" | $NCCMD > $VPNUP; chmod +x $VPNUP
		wget $DLDIR$VPNUP && chmod +x $VPNUP && break || echo "$INFO failed, trying again"
	else
		wget $DLDIR$VPNUP && chmod +x $VPNUP && break || echo "$INFO failed, trying again"
	fi
	if [ $(wc -l $VPNUP | awk '{print $1}') -ne 0 ]; then break; else echo "$INFO failed, retry"; fi
	sleep 3
done

for i in 1 2 3 4 5
do
	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") getting vpndown.sh" >> $VPNLOG
	if [ $(which nc) ]; then
		#echo -e "GET $DLDIR$VPNDOWN HTTP/1.0\n\n" | $NCCMD > $VPNDOWN; chmod +x $VPNDOWN
		wget $DLDIR$VPNDOWN && chmod +x $VPNDOWN && break || echo "$INFO failed, trying again"
	else
		wget $DLDIR$VPNDOWN && chmod +x $VPNDOWN && break || echo "$INFO failed, trying again"
	fi
	if [ $(wc -l $VPNDOWN | awk '{print $1}') -ne 0 ]; then break; else echo "$INFO failed, retry"; fi
	sleep 3
done

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") modifying $IPUP" >> $VPNLOG

for i in 1 2 3 4 5 6 7 8 9 10 11 12
do
	if [ -e $IPUP ]; then
		sed -ie 's#exit 0#/tmp/vpnup.sh pptp\nexit 0#g' $IPUP
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") $IPUP modified" >> $VPNLOG
		break
	else
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") $IPUP not exists, sleep 10sec." >> $VPNLOG
		sleep 10
	fi
done

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") modifying $IPDOWN" >> $VPNLOG
if [ -e $IPDOWN ]; then
	sed -ie 's#exit 0#/tmp/vpndown.sh pptp\nexit 0#g' $IPDOWN
	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") $IPDOWN modified" >> $VPNLOG
else
	echo "$IPDOWN not exists" >> $VPNLOG
fi
	
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") ALL DONE. Let's wait for VPN being connected." >> $VPNLOG


