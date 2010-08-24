#!/bin/sh

set -x
export PATH="/bin:/sbin:/usr/sbin:/usr/bin"

LOG='/tmp/autoddvpn.log'
LOCK='/tmp/autoddvpn.lock'
PID=$$
EXROUTEDIR='/jffs/exroute.d'
INFO="[INFO#${PID}]"
DEBUG="[DEBUG#${PID}]"
ERROR="[ERROR#${PID}]"

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpnup.sh started" >> $LOG
for i in 1 2 3 4 5 6
do
	if [ -f $LOCK ]; then
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") got $LOCK , sleep 10 secs. #$i/6" >> $LOG
		sleep 10
	else
		break
	fi
done

if [ -f $LOCK ]; then
   echo "$ERROR $(date "+%d/%b/%Y:%H:%M:%S") still got $LOCK , I'm aborted. Fix me." >> $LOG
   exit 0
fi
#else
#	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") $LOCK was released, let's continue." >> $LOG
#fi

# create the lock
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpnup" >> $LOCK
	
	

OLDGW=$(nvram get wan_gateway)

case $1 in
	"pptp")
		case "$(nvram get router_name)" in
			"tomato")
				VPNSRV=$(nvram get pptpd_client_srvip)
				VPNSRVSUB=$(nvram get pptpd_client_srvsub)
				PPTPDEV=$(nvram get pptp_client_iface)
				VPNGW=$(nvram get pptp_client_gateway)
				;;
			"DD-WRT")
				VPNSRV=$(nvram get pptpd_client_srvip)
				VPNSRVSUB=$(nvram get pptpd_client_srvsub)
				PPTPDEV=$(route -n | grep ^$VPNSRVSUB | awk '{print $NF}')
				VPNGW=$(ifconfig $PPTPDEV | grep -Eo "P-t-P:([0-9.]+)" | cut -d: -f2)
				;;
		esac
		;;
	"openvpn")
		VPNSRV=$(nvram get openvpncl_remoteip)
		#OPENVPNSRVSUB=$(nvram get OPENVPNd_client_srvsub)
		#OPENVPNDEV=$(route | grep ^$OPENVPNSRVSUB | awk '{print $NF}')
		OPENVPNDEV='tun0'
		VPNGW=$(ifconfig $OPENVPNDEV | grep -Eo "P-t-P:([0-9.]+)" | cut -d: -f2)
		;;
	*)
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") unknown vpnup.sh parameter,quit." >> $LOCK
		exit 1
esac



if [ $OLDGW == '' ]; then
	echo "$ERROR OLDGW is empty, is the WAN disconnected?" >> $LOG
	exit 0
else
	echo "$INFO OLDGW is $OLDGW" 
fi

route add -host $VPNSRV gw $OLDGW
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") delete default gw $OLDGW"  >> $LOG
route del default gw $OLDGW

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") add default gw $VPNGW"  >> $LOG
route add default gw $VPNGW

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") adding the static routes, this may take a while." >> $LOG

##### begin batch route #####
route add -net 1.12.0.0/14 gw $OLDGW
route add -net 1.24.0.0/13 gw $OLDGW
route add -net 1.45.0.0/16 gw $OLDGW
route add -net 1.48.0.0/15 gw $OLDGW
route add -net 1.51.0.0/16 gw $OLDGW
route add -net 1.56.0.0/13 gw $OLDGW
route add -net 1.68.0.0/14 gw $OLDGW
route add -net 1.80.0.0/12 gw $OLDGW
route add -net 1.116.0.0/14 gw $OLDGW
route add -net 1.180.0.0/14 gw $OLDGW
route add -net 1.184.0.0/15 gw $OLDGW
route add -net 1.188.0.0/14 gw $OLDGW
route add -net 1.192.0.0/13 gw $OLDGW
route add -net 1.202.0.0/15 gw $OLDGW
route add -net 1.204.0.0/14 gw $OLDGW
route add -net 110.6.0.0/15 gw $OLDGW
route add -net 110.16.0.0/14 gw $OLDGW
route add -net 110.40.0.0/14 gw $OLDGW
route add -net 110.48.0.0/16 gw $OLDGW
route add -net 110.51.0.0/16 gw $OLDGW
route add -net 110.52.0.0/15 gw $OLDGW
route add -net 110.56.0.0/13 gw $OLDGW
route add -net 110.64.0.0/15 gw $OLDGW
route add -net 110.72.0.0/15 gw $OLDGW
route add -net 110.75.0.0/16 gw $OLDGW
route add -net 110.76.0.0/18 gw $OLDGW
route add -net 110.76.192.0/18 gw $OLDGW
route add -net 110.77.0.0/17 gw $OLDGW
route add -net 110.80.0.0/13 gw $OLDGW
route add -net 110.88.0.0/14 gw $OLDGW
route add -net 110.94.0.0/15 gw $OLDGW
route add -net 110.96.0.0/11 gw $OLDGW
route add -net 110.152.0.0/14 gw $OLDGW
route add -net 110.156.0.0/15 gw $OLDGW
route add -net 110.165.32.0/19 gw $OLDGW
route add -net 110.166.0.0/15 gw $OLDGW
route add -net 110.172.192.0/18 gw $OLDGW
route add -net 110.173.0.0/19 gw $OLDGW
route add -net 110.173.32.0/20 gw $OLDGW
route add -net 110.173.64.0/18 gw $OLDGW
route add -net 110.173.192.0/19 gw $OLDGW
route add -net 110.176.0.0/12 gw $OLDGW
route add -net 110.192.0.0/11 gw $OLDGW
route add -net 110.228.0.0/14 gw $OLDGW
route add -net 110.232.32.0/19 gw $OLDGW
route add -net 110.236.0.0/15 gw $OLDGW
route add -net 110.240.0.0/12 gw $OLDGW
route add -net 111.0.0.0/10 gw $OLDGW
route add -net 111.66.0.0/16 gw $OLDGW
route add -net 111.67.192.0/20 gw $OLDGW
route add -net 111.68.64.0/19 gw $OLDGW
route add -net 111.72.0.0/13 gw $OLDGW
route add -net 111.85.0.0/16 gw $OLDGW
route add -net 111.91.192.0/19 gw $OLDGW
route add -net 111.112.0.0/14 gw $OLDGW
route add -net 111.116.0.0/15 gw $OLDGW
route add -net 111.119.64.0/18 gw $OLDGW
route add -net 111.119.128.0/19 gw $OLDGW
route add -net 111.120.0.0/14 gw $OLDGW
route add -net 111.124.0.0/16 gw $OLDGW
route add -net 111.126.0.0/15 gw $OLDGW
route add -net 111.128.0.0/11 gw $OLDGW
route add -net 111.160.0.0/13 gw $OLDGW
route add -net 111.170.0.0/16 gw $OLDGW
route add -net 111.172.0.0/14 gw $OLDGW
route add -net 111.176.0.0/13 gw $OLDGW
route add -net 111.186.0.0/15 gw $OLDGW
route add -net 111.192.0.0/12 gw $OLDGW
route add -net 111.208.0.0/13 gw $OLDGW
route add -net 111.221.128.0/17 gw $OLDGW
route add -net 111.222.0.0/16 gw $OLDGW
route add -net 111.223.240.0/22 gw $OLDGW
route add -net 111.223.248.0/22 gw $OLDGW
route add -net 111.224.0.0/13 gw $OLDGW
route add -net 111.235.96.0/19 gw $OLDGW
route add -net 111.235.160.0/19 gw $OLDGW
route add -net 112.0.0.0/10 gw $OLDGW
route add -net 112.64.0.0/14 gw $OLDGW
route add -net 112.73.0.0/16 gw $OLDGW
route add -net 112.74.0.0/15 gw $OLDGW
route add -net 112.80.0.0/12 gw $OLDGW
route add -net 112.96.0.0/13 gw $OLDGW
route add -net 112.109.128.0/17 gw $OLDGW
route add -net 112.111.0.0/16 gw $OLDGW
route add -net 112.112.0.0/14 gw $OLDGW
route add -net 112.116.0.0/15 gw $OLDGW
route add -net 112.122.0.0/15 gw $OLDGW
route add -net 112.124.0.0/14 gw $OLDGW
route add -net 112.128.0.0/14 gw $OLDGW
route add -net 112.132.0.0/16 gw $OLDGW
route add -net 112.192.0.0/14 gw $OLDGW
route add -net 112.224.0.0/11 gw $OLDGW
route add -net 113.0.0.0/13 gw $OLDGW
route add -net 113.8.0.0/15 gw $OLDGW
route add -net 113.11.192.0/19 gw $OLDGW
route add -net 113.12.0.0/14 gw $OLDGW
route add -net 113.16.0.0/15 gw $OLDGW
route add -net 113.18.0.0/16 gw $OLDGW
route add -net 113.24.0.0/14 gw $OLDGW
route add -net 113.31.0.0/16 gw $OLDGW
route add -net 113.44.0.0/14 gw $OLDGW
route add -net 113.48.0.0/14 gw $OLDGW
route add -net 113.52.160.0/19 gw $OLDGW
route add -net 113.54.0.0/15 gw $OLDGW
route add -net 113.56.0.0/15 gw $OLDGW
route add -net 113.58.0.0/16 gw $OLDGW
route add -net 113.59.0.0/17 gw $OLDGW
route add -net 113.62.0.0/15 gw $OLDGW
route add -net 113.64.0.0/10 gw $OLDGW
route add -net 113.128.0.0/15 gw $OLDGW
route add -net 113.130.96.0/20 gw $OLDGW
route add -net 113.130.112.0/21 gw $OLDGW
route add -net 113.132.0.0/14 gw $OLDGW
route add -net 113.136.0.0/13 gw $OLDGW
route add -net 113.194.0.0/15 gw $OLDGW
route add -net 113.200.0.0/15 gw $OLDGW
route add -net 113.202.0.0/16 gw $OLDGW
route add -net 113.204.0.0/14 gw $OLDGW
route add -net 113.208.96.0/19 gw $OLDGW
route add -net 113.208.128.0/17 gw $OLDGW
route add -net 113.209.0.0/16 gw $OLDGW
route add -net 113.212.0.0/18 gw $OLDGW
route add -net 113.213.0.0/17 gw $OLDGW
route add -net 113.214.0.0/15 gw $OLDGW
route add -net 113.218.0.0/15 gw $OLDGW
route add -net 113.220.0.0/14 gw $OLDGW
route add -net 113.224.0.0/12 gw $OLDGW
route add -net 113.240.0.0/13 gw $OLDGW
route add -net 113.248.0.0/14 gw $OLDGW
route add -net 114.28.0.0/16 gw $OLDGW
route add -net 114.54.0.0/15 gw $OLDGW
route add -net 114.60.0.0/14 gw $OLDGW
route add -net 114.64.0.0/14 gw $OLDGW
route add -net 114.68.0.0/16 gw $OLDGW
route add -net 114.80.0.0/12 gw $OLDGW
route add -net 114.96.0.0/13 gw $OLDGW
route add -net 114.104.0.0/14 gw $OLDGW
route add -net 114.110.0.0/20 gw $OLDGW
route add -net 114.110.64.0/18 gw $OLDGW
route add -net 114.110.128.0/17 gw $OLDGW
route add -net 114.111.0.0/19 gw $OLDGW
route add -net 114.111.160.0/19 gw $OLDGW
route add -net 114.112.0.0/13 gw $OLDGW
route add -net 114.132.0.0/16 gw $OLDGW
route add -net 114.135.0.0/16 gw $OLDGW
route add -net 114.138.0.0/15 gw $OLDGW
route add -net 114.141.128.0/18 gw $OLDGW
route add -net 114.196.0.0/15 gw $OLDGW
route add -net 114.208.0.0/12 gw $OLDGW
route add -net 114.224.0.0/11 gw $OLDGW
route add -net 115.24.0.0/14 gw $OLDGW
route add -net 115.28.0.0/15 gw $OLDGW
route add -net 115.32.0.0/14 gw $OLDGW
route add -net 115.44.0.0/14 gw $OLDGW
route add -net 115.48.0.0/12 gw $OLDGW
route add -net 115.84.0.0/18 gw $OLDGW
route add -net 115.84.192.0/19 gw $OLDGW
route add -net 115.85.192.0/18 gw $OLDGW
route add -net 115.100.0.0/14 gw $OLDGW
route add -net 115.104.0.0/14 gw $OLDGW
route add -net 115.120.0.0/14 gw $OLDGW
route add -net 115.124.16.0/20 gw $OLDGW
route add -net 115.148.0.0/14 gw $OLDGW
route add -net 115.152.0.0/13 gw $OLDGW
route add -net 115.168.0.0/13 gw $OLDGW
route add -net 115.180.0.0/14 gw $OLDGW
route add -net 115.192.0.0/11 gw $OLDGW
route add -net 115.224.0.0/12 gw $OLDGW
route add -net 116.1.0.0/16 gw $OLDGW
route add -net 116.2.0.0/15 gw $OLDGW
route add -net 116.4.0.0/14 gw $OLDGW
route add -net 116.8.0.0/14 gw $OLDGW
route add -net 116.13.0.0/16 gw $OLDGW
route add -net 116.16.0.0/12 gw $OLDGW
route add -net 116.52.0.0/14 gw $OLDGW
route add -net 116.56.0.0/15 gw $OLDGW
route add -net 116.58.128.0/20 gw $OLDGW
route add -net 116.58.208.0/20 gw $OLDGW
route add -net 116.60.0.0/14 gw $OLDGW
route add -net 116.66.0.0/17 gw $OLDGW
route add -net 116.69.0.0/16 gw $OLDGW
route add -net 116.70.0.0/17 gw $OLDGW
route add -net 116.76.0.0/14 gw $OLDGW
route add -net 116.89.144.0/20 gw $OLDGW
route add -net 116.90.80.0/20 gw $OLDGW
route add -net 116.90.184.0/21 gw $OLDGW
route add -net 116.95.0.0/16 gw $OLDGW
route add -net 116.112.0.0/14 gw $OLDGW
route add -net 116.116.0.0/15 gw $OLDGW
route add -net 116.128.0.0/10 gw $OLDGW
route add -net 116.192.0.0/16 gw $OLDGW
route add -net 116.193.16.0/20 gw $OLDGW
route add -net 116.193.32.0/19 gw $OLDGW
route add -net 116.194.0.0/15 gw $OLDGW
route add -net 116.196.0.0/16 gw $OLDGW
route add -net 116.198.0.0/16 gw $OLDGW
route add -net 116.199.0.0/17 gw $OLDGW
route add -net 116.199.128.0/19 gw $OLDGW
route add -net 116.204.0.0/15 gw $OLDGW
route add -net 116.207.0.0/16 gw $OLDGW
route add -net 116.208.0.0/14 gw $OLDGW
route add -net 116.212.160.0/20 gw $OLDGW
route add -net 116.213.64.0/18 gw $OLDGW
route add -net 116.213.128.0/17 gw $OLDGW
route add -net 116.214.32.0/19 gw $OLDGW
route add -net 116.214.64.0/20 gw $OLDGW
route add -net 116.214.128.0/17 gw $OLDGW
route add -net 116.215.0.0/16 gw $OLDGW
route add -net 116.216.0.0/14 gw $OLDGW
route add -net 116.224.0.0/12 gw $OLDGW
route add -net 116.242.0.0/15 gw $OLDGW
route add -net 116.244.0.0/14 gw $OLDGW
route add -net 116.248.0.0/15 gw $OLDGW
route add -net 116.252.0.0/15 gw $OLDGW
route add -net 116.254.128.0/17 gw $OLDGW
route add -net 116.255.128.0/17 gw $OLDGW
route add -net 117.8.0.0/13 gw $OLDGW
route add -net 117.21.0.0/16 gw $OLDGW
route add -net 117.22.0.0/15 gw $OLDGW
route add -net 117.24.0.0/13 gw $OLDGW
route add -net 117.32.0.0/13 gw $OLDGW
route add -net 117.40.0.0/14 gw $OLDGW
route add -net 117.44.0.0/15 gw $OLDGW
route add -net 117.48.0.0/14 gw $OLDGW
route add -net 117.53.48.0/20 gw $OLDGW
route add -net 117.53.176.0/20 gw $OLDGW
route add -net 117.57.0.0/16 gw $OLDGW
route add -net 117.58.0.0/17 gw $OLDGW
route add -net 117.59.0.0/16 gw $OLDGW
route add -net 117.60.0.0/14 gw $OLDGW
route add -net 117.64.0.0/13 gw $OLDGW
route add -net 117.72.0.0/15 gw $OLDGW
route add -net 117.74.64.0/20 gw $OLDGW
route add -net 117.74.128.0/17 gw $OLDGW
route add -net 117.75.0.0/16 gw $OLDGW
route add -net 117.76.0.0/14 gw $OLDGW
route add -net 117.80.0.0/12 gw $OLDGW
route add -net 117.100.0.0/15 gw $OLDGW
route add -net 117.103.16.0/20 gw $OLDGW
route add -net 117.103.128.0/20 gw $OLDGW
route add -net 117.106.0.0/15 gw $OLDGW
route add -net 117.112.0.0/13 gw $OLDGW
route add -net 117.120.64.0/18 gw $OLDGW
route add -net 117.120.128.0/17 gw $OLDGW
route add -net 117.121.0.0/17 gw $OLDGW
route add -net 117.121.128.0/18 gw $OLDGW
route add -net 117.121.192.0/21 gw $OLDGW
route add -net 117.122.128.0/17 gw $OLDGW
route add -net 117.124.0.0/14 gw $OLDGW
route add -net 117.128.0.0/10 gw $OLDGW
route add -net 118.24.0.0/13 gw $OLDGW
route add -net 118.64.0.0/15 gw $OLDGW
route add -net 118.66.0.0/16 gw $OLDGW
route add -net 118.67.112.0/20 gw $OLDGW
route add -net 118.72.0.0/13 gw $OLDGW
route add -net 118.80.0.0/15 gw $OLDGW
route add -net 118.84.0.0/15 gw $OLDGW
route add -net 118.88.32.0/19 gw $OLDGW
route add -net 118.88.64.0/18 gw $OLDGW
route add -net 118.88.128.0/17 gw $OLDGW
route add -net 118.89.0.0/16 gw $OLDGW
route add -net 118.91.240.0/20 gw $OLDGW
route add -net 118.102.16.0/20 gw $OLDGW
route add -net 118.112.0.0/13 gw $OLDGW
route add -net 118.120.0.0/14 gw $OLDGW
route add -net 118.124.0.0/15 gw $OLDGW
route add -net 118.126.0.0/16 gw $OLDGW
route add -net 118.132.0.0/14 gw $OLDGW
route add -net 118.144.0.0/14 gw $OLDGW
route add -net 118.178.0.0/16 gw $OLDGW
route add -net 118.180.0.0/14 gw $OLDGW
route add -net 118.184.0.0/13 gw $OLDGW
route add -net 118.192.0.0/12 gw $OLDGW
route add -net 118.212.0.0/15 gw $OLDGW
route add -net 118.224.0.0/14 gw $OLDGW
route add -net 118.228.0.0/15 gw $OLDGW
route add -net 118.230.0.0/16 gw $OLDGW
route add -net 118.239.0.0/16 gw $OLDGW
route add -net 118.242.0.0/16 gw $OLDGW
route add -net 118.244.0.0/14 gw $OLDGW
route add -net 118.248.0.0/13 gw $OLDGW
route add -net 119.0.0.0/15 gw $OLDGW
route add -net 119.2.0.0/19 gw $OLDGW
route add -net 119.2.128.0/17 gw $OLDGW
route add -net 119.3.0.0/16 gw $OLDGW
route add -net 119.4.0.0/14 gw $OLDGW
route add -net 119.8.0.0/15 gw $OLDGW
route add -net 119.10.0.0/17 gw $OLDGW
route add -net 119.15.136.0/21 gw $OLDGW
route add -net 119.16.0.0/16 gw $OLDGW
route add -net 119.18.192.0/20 gw $OLDGW
route add -net 119.18.208.0/21 gw $OLDGW
route add -net 119.18.224.0/19 gw $OLDGW
route add -net 119.19.0.0/16 gw $OLDGW
route add -net 119.20.0.0/14 gw $OLDGW
route add -net 119.27.64.0/18 gw $OLDGW
route add -net 119.27.160.0/19 gw $OLDGW
route add -net 119.27.192.0/18 gw $OLDGW
route add -net 119.28.0.0/15 gw $OLDGW
route add -net 119.30.48.0/20 gw $OLDGW
route add -net 119.31.192.0/19 gw $OLDGW
route add -net 119.32.0.0/13 gw $OLDGW
route add -net 119.40.0.0/18 gw $OLDGW
route add -net 119.40.64.0/20 gw $OLDGW
route add -net 119.40.128.0/17 gw $OLDGW
route add -net 119.41.0.0/16 gw $OLDGW
route add -net 119.42.0.0/18 gw $OLDGW
route add -net 119.42.136.0/21 gw $OLDGW
route add -net 119.42.224.0/19 gw $OLDGW
route add -net 119.44.0.0/15 gw $OLDGW
route add -net 119.48.0.0/13 gw $OLDGW
route add -net 119.57.0.0/16 gw $OLDGW
route add -net 119.58.0.0/16 gw $OLDGW
route add -net 119.59.128.0/17 gw $OLDGW
route add -net 119.60.0.0/15 gw $OLDGW
route add -net 119.62.0.0/16 gw $OLDGW
route add -net 119.63.32.0/19 gw $OLDGW
route add -net 119.75.208.0/20 gw $OLDGW
route add -net 119.78.0.0/15 gw $OLDGW
route add -net 119.80.0.0/15 gw $OLDGW
route add -net 119.84.0.0/14 gw $OLDGW
route add -net 119.88.0.0/14 gw $OLDGW
route add -net 119.96.0.0/13 gw $OLDGW
route add -net 119.108.0.0/15 gw $OLDGW
route add -net 119.112.0.0/12 gw $OLDGW
route add -net 119.128.0.0/12 gw $OLDGW
route add -net 119.144.0.0/14 gw $OLDGW
route add -net 119.148.160.0/20 gw $OLDGW
route add -net 119.161.128.0/17 gw $OLDGW
route add -net 119.162.0.0/15 gw $OLDGW
route add -net 119.164.0.0/14 gw $OLDGW
route add -net 119.176.0.0/12 gw $OLDGW
route add -net 119.232.0.0/15 gw $OLDGW
route add -net 119.235.128.0/18 gw $OLDGW
route add -net 119.248.0.0/14 gw $OLDGW
route add -net 119.253.0.0/16 gw $OLDGW
route add -net 119.254.0.0/15 gw $OLDGW
route add -net 120.0.0.0/12 gw $OLDGW
route add -net 120.24.0.0/14 gw $OLDGW
route add -net 120.30.0.0/15 gw $OLDGW
route add -net 120.32.0.0/12 gw $OLDGW
route add -net 120.48.0.0/15 gw $OLDGW
route add -net 120.52.0.0/14 gw $OLDGW
route add -net 120.64.0.0/13 gw $OLDGW
route add -net 120.72.32.0/19 gw $OLDGW
route add -net 120.72.128.0/17 gw $OLDGW
route add -net 120.76.0.0/14 gw $OLDGW
route add -net 120.80.0.0/13 gw $OLDGW
route add -net 120.88.8.0/21 gw $OLDGW
route add -net 120.90.0.0/15 gw $OLDGW
route add -net 120.92.0.0/16 gw $OLDGW
route add -net 120.94.0.0/15 gw $OLDGW
route add -net 120.128.0.0/13 gw $OLDGW
route add -net 120.136.128.0/18 gw $OLDGW
route add -net 120.137.0.0/17 gw $OLDGW
route add -net 120.192.0.0/10 gw $OLDGW
route add -net 121.0.16.0/20 gw $OLDGW
route add -net 121.4.0.0/15 gw $OLDGW
route add -net 121.8.0.0/13 gw $OLDGW
route add -net 121.16.0.0/12 gw $OLDGW
route add -net 121.32.0.0/13 gw $OLDGW
route add -net 121.40.0.0/14 gw $OLDGW
route add -net 121.46.0.0/15 gw $OLDGW
route add -net 121.48.0.0/15 gw $OLDGW
route add -net 121.51.0.0/16 gw $OLDGW
route add -net 121.52.160.0/19 gw $OLDGW
route add -net 121.52.208.0/20 gw $OLDGW
route add -net 121.52.224.0/19 gw $OLDGW
route add -net 121.55.0.0/18 gw $OLDGW
route add -net 121.56.0.0/15 gw $OLDGW
route add -net 121.58.0.0/17 gw $OLDGW
route add -net 121.58.144.0/20 gw $OLDGW
route add -net 121.59.0.0/16 gw $OLDGW
route add -net 121.60.0.0/14 gw $OLDGW
route add -net 121.68.0.0/14 gw $OLDGW
route add -net 121.76.0.0/15 gw $OLDGW
route add -net 121.79.128.0/18 gw $OLDGW
route add -net 121.89.0.0/16 gw $OLDGW
route add -net 121.100.128.0/17 gw $OLDGW
route add -net 121.101.208.0/20 gw $OLDGW
route add -net 121.192.0.0/13 gw $OLDGW
route add -net 121.201.0.0/16 gw $OLDGW
route add -net 121.204.0.0/14 gw $OLDGW
route add -net 121.224.0.0/12 gw $OLDGW
route add -net 121.248.0.0/14 gw $OLDGW
route add -net 121.255.0.0/16 gw $OLDGW
route add -net 122.0.64.0/18 gw $OLDGW
route add -net 122.0.128.0/17 gw $OLDGW
route add -net 122.4.0.0/14 gw $OLDGW
route add -net 122.8.0.0/13 gw $OLDGW
route add -net 122.48.0.0/16 gw $OLDGW
route add -net 122.49.0.0/18 gw $OLDGW
route add -net 122.51.0.0/16 gw $OLDGW
route add -net 122.64.0.0/11 gw $OLDGW
route add -net 122.96.0.0/15 gw $OLDGW
route add -net 122.102.0.0/20 gw $OLDGW
route add -net 122.102.64.0/19 gw $OLDGW
route add -net 122.112.0.0/14 gw $OLDGW
route add -net 122.119.0.0/16 gw $OLDGW
route add -net 122.136.0.0/13 gw $OLDGW
route add -net 122.144.128.0/17 gw $OLDGW
route add -net 122.152.192.0/18 gw $OLDGW
route add -net 122.156.0.0/14 gw $OLDGW
route add -net 122.192.0.0/14 gw $OLDGW
route add -net 122.198.0.0/16 gw $OLDGW
route add -net 122.200.64.0/18 gw $OLDGW
route add -net 122.204.0.0/14 gw $OLDGW
route add -net 122.224.0.0/12 gw $OLDGW
route add -net 122.240.0.0/13 gw $OLDGW
route add -net 122.248.48.0/20 gw $OLDGW
route add -net 123.0.128.0/18 gw $OLDGW
route add -net 123.4.0.0/14 gw $OLDGW
route add -net 123.8.0.0/13 gw $OLDGW
route add -net 123.49.128.0/17 gw $OLDGW
route add -net 123.52.0.0/14 gw $OLDGW
route add -net 123.56.0.0/13 gw $OLDGW
route add -net 123.64.0.0/11 gw $OLDGW
route add -net 123.96.0.0/15 gw $OLDGW
route add -net 123.98.0.0/17 gw $OLDGW
route add -net 123.99.128.0/17 gw $OLDGW
route add -net 123.100.0.0/19 gw $OLDGW
route add -net 123.101.0.0/16 gw $OLDGW
route add -net 123.103.0.0/17 gw $OLDGW
route add -net 123.108.128.0/20 gw $OLDGW
route add -net 123.108.208.0/20 gw $OLDGW
route add -net 123.112.0.0/12 gw $OLDGW
route add -net 123.128.0.0/13 gw $OLDGW
route add -net 123.136.80.0/20 gw $OLDGW
route add -net 123.137.0.0/16 gw $OLDGW
route add -net 123.138.0.0/15 gw $OLDGW
route add -net 123.144.0.0/12 gw $OLDGW
route add -net 123.160.0.0/12 gw $OLDGW
route add -net 123.176.80.0/20 gw $OLDGW
route add -net 123.177.0.0/16 gw $OLDGW
route add -net 123.178.0.0/15 gw $OLDGW
route add -net 123.180.0.0/14 gw $OLDGW
route add -net 123.184.0.0/13 gw $OLDGW
route add -net 123.196.0.0/15 gw $OLDGW
route add -net 123.199.128.0/17 gw $OLDGW
route add -net 123.206.0.0/15 gw $OLDGW
route add -net 123.232.0.0/14 gw $OLDGW
route add -net 123.242.0.0/17 gw $OLDGW
route add -net 123.244.0.0/14 gw $OLDGW
route add -net 123.249.0.0/16 gw $OLDGW
route add -net 123.253.0.0/16 gw $OLDGW
route add -net 124.6.64.0/18 gw $OLDGW
route add -net 124.14.0.0/15 gw $OLDGW
route add -net 124.16.0.0/15 gw $OLDGW
route add -net 124.20.0.0/14 gw $OLDGW
route add -net 124.28.192.0/18 gw $OLDGW
route add -net 124.29.0.0/17 gw $OLDGW
route add -net 124.31.0.0/16 gw $OLDGW
route add -net 124.40.112.0/20 gw $OLDGW
route add -net 124.40.128.0/18 gw $OLDGW
route add -net 124.42.0.0/16 gw $OLDGW
route add -net 124.47.0.0/18 gw $OLDGW
route add -net 124.64.0.0/15 gw $OLDGW
route add -net 124.66.0.0/17 gw $OLDGW
route add -net 124.67.0.0/16 gw $OLDGW
route add -net 124.68.0.0/14 gw $OLDGW
route add -net 124.72.0.0/13 gw $OLDGW
route add -net 124.88.0.0/13 gw $OLDGW
route add -net 124.108.8.0/21 gw $OLDGW
route add -net 124.108.40.0/21 gw $OLDGW
route add -net 124.112.0.0/13 gw $OLDGW
route add -net 124.126.0.0/15 gw $OLDGW
route add -net 124.128.0.0/13 gw $OLDGW
route add -net 124.147.128.0/17 gw $OLDGW
route add -net 124.151.0.0/16 gw $OLDGW
route add -net 124.156.0.0/16 gw $OLDGW
route add -net 124.160.0.0/13 gw $OLDGW
route add -net 124.172.0.0/14 gw $OLDGW
route add -net 124.192.0.0/15 gw $OLDGW
route add -net 124.196.0.0/16 gw $OLDGW
route add -net 124.200.0.0/13 gw $OLDGW
route add -net 124.220.0.0/14 gw $OLDGW
route add -net 124.224.0.0/12 gw $OLDGW
route add -net 124.240.0.0/17 gw $OLDGW
route add -net 124.240.128.0/18 gw $OLDGW
route add -net 124.242.0.0/16 gw $OLDGW
route add -net 124.243.192.0/18 gw $OLDGW
route add -net 124.248.0.0/17 gw $OLDGW
route add -net 124.249.0.0/16 gw $OLDGW
route add -net 124.250.0.0/15 gw $OLDGW
route add -net 124.254.0.0/18 gw $OLDGW
route add -net 125.31.192.0/18 gw $OLDGW
route add -net 125.32.0.0/12 gw $OLDGW
route add -net 125.58.128.0/17 gw $OLDGW
route add -net 125.61.128.0/17 gw $OLDGW
route add -net 125.62.0.0/18 gw $OLDGW
route add -net 125.64.0.0/11 gw $OLDGW
route add -net 125.96.0.0/15 gw $OLDGW
route add -net 125.98.0.0/16 gw $OLDGW
route add -net 125.104.0.0/13 gw $OLDGW
route add -net 125.112.0.0/12 gw $OLDGW
route add -net 125.169.0.0/16 gw $OLDGW
route add -net 125.171.0.0/16 gw $OLDGW
route add -net 125.208.0.0/18 gw $OLDGW
route add -net 125.210.0.0/15 gw $OLDGW
route add -net 125.213.0.0/17 gw $OLDGW
route add -net 125.214.96.0/19 gw $OLDGW
route add -net 125.215.0.0/18 gw $OLDGW
route add -net 125.216.0.0/13 gw $OLDGW
route add -net 125.254.128.0/17 gw $OLDGW
route add -net 134.196.0.0/16 gw $OLDGW
route add -net 14.103.0.0/16 gw $OLDGW
route add -net 159.226.0.0/16 gw $OLDGW
route add -net 161.207.0.0/16 gw $OLDGW
route add -net 162.105.0.0/16 gw $OLDGW
route add -net 166.111.0.0/16 gw $OLDGW
route add -net 167.139.0.0/16 gw $OLDGW
route add -net 168.160.0.0/16 gw $OLDGW
route add -net 175.0.0.0/12 gw $OLDGW
route add -net 175.16.0.0/13 gw $OLDGW
route add -net 175.24.0.0/14 gw $OLDGW
route add -net 175.30.0.0/15 gw $OLDGW
route add -net 175.42.0.0/15 gw $OLDGW
route add -net 175.44.0.0/16 gw $OLDGW
route add -net 175.46.0.0/15 gw $OLDGW
route add -net 175.48.0.0/12 gw $OLDGW
route add -net 175.64.0.0/11 gw $OLDGW
route add -net 175.102.0.0/16 gw $OLDGW
route add -net 175.106.128.0/17 gw $OLDGW
route add -net 175.146.0.0/15 gw $OLDGW
route add -net 175.148.0.0/14 gw $OLDGW
route add -net 175.152.0.0/14 gw $OLDGW
route add -net 175.160.0.0/12 gw $OLDGW
route add -net 175.178.0.0/16 gw $OLDGW
route add -net 175.184.128.0/18 gw $OLDGW
route add -net 175.185.0.0/16 gw $OLDGW
route add -net 175.186.0.0/15 gw $OLDGW
route add -net 175.188.0.0/14 gw $OLDGW
route add -net 180.76.0.0/14 gw $OLDGW
route add -net 180.84.0.0/15 gw $OLDGW
route add -net 180.86.0.0/16 gw $OLDGW
route add -net 180.88.0.0/14 gw $OLDGW
route add -net 180.94.56.0/21 gw $OLDGW
route add -net 180.94.96.0/20 gw $OLDGW
route add -net 180.95.128.0/17 gw $OLDGW
route add -net 180.96.0.0/11 gw $OLDGW
route add -net 180.129.128.0/17 gw $OLDGW
route add -net 180.130.0.0/16 gw $OLDGW
route add -net 180.136.0.0/13 gw $OLDGW
route add -net 180.148.224.0/19 gw $OLDGW
route add -net 180.149.128.0/19 gw $OLDGW
route add -net 180.150.160.0/19 gw $OLDGW
route add -net 180.152.0.0/13 gw $OLDGW
route add -net 180.160.0.0/12 gw $OLDGW
route add -net 180.178.192.0/18 gw $OLDGW
route add -net 180.184.0.0/14 gw $OLDGW
route add -net 180.188.0.0/17 gw $OLDGW
route add -net 180.189.148.0/22 gw $OLDGW
route add -net 180.200.252.0/22 gw $OLDGW
route add -net 180.201.0.0/16 gw $OLDGW
route add -net 180.202.0.0/15 gw $OLDGW
route add -net 180.208.0.0/15 gw $OLDGW
route add -net 180.210.224.0/19 gw $OLDGW
route add -net 180.212.0.0/15 gw $OLDGW
route add -net 180.222.224.0/19 gw $OLDGW
route add -net 180.223.0.0/16 gw $OLDGW
route add -net 180.233.0.0/18 gw $OLDGW
route add -net 180.233.64.0/19 gw $OLDGW
route add -net 180.235.64.0/19 gw $OLDGW
route add -net 182.16.192.0/19 gw $OLDGW
route add -net 182.18.0.0/17 gw $OLDGW
route add -net 182.32.0.0/12 gw $OLDGW
route add -net 182.48.96.0/19 gw $OLDGW
route add -net 182.49.0.0/16 gw $OLDGW
route add -net 182.50.0.0/20 gw $OLDGW
route add -net 182.50.112.0/20 gw $OLDGW
route add -net 182.51.0.0/16 gw $OLDGW
route add -net 182.54.0.0/17 gw $OLDGW
route add -net 182.61.0.0/16 gw $OLDGW
route add -net 182.80.0.0/13 gw $OLDGW
route add -net 182.88.0.0/14 gw $OLDGW
route add -net 182.92.0.0/16 gw $OLDGW
route add -net 182.96.0.0/11 gw $OLDGW
route add -net 182.128.0.0/12 gw $OLDGW
route add -net 182.144.0.0/13 gw $OLDGW
route add -net 182.157.0.0/16 gw $OLDGW
route add -net 182.160.64.0/19 gw $OLDGW
route add -net 182.174.0.0/15 gw $OLDGW
route add -net 182.200.0.0/13 gw $OLDGW
route add -net 182.236.128.0/17 gw $OLDGW
route add -net 182.238.0.0/16 gw $OLDGW
route add -net 182.239.0.0/19 gw $OLDGW
route add -net 182.240.0.0/13 gw $OLDGW
route add -net 182.254.0.0/16 gw $OLDGW
route add -net 183.0.0.0/10 gw $OLDGW
route add -net 183.64.0.0/13 gw $OLDGW
route add -net 183.81.180.0/22 gw $OLDGW
route add -net 183.84.0.0/15 gw $OLDGW
route add -net 183.91.128.0/22 gw $OLDGW
route add -net 183.91.144.0/20 gw $OLDGW
route add -net 183.92.0.0/14 gw $OLDGW
route add -net 183.128.0.0/11 gw $OLDGW
route add -net 183.160.0.0/13 gw $OLDGW
route add -net 183.168.0.0/15 gw $OLDGW
route add -net 183.170.0.0/16 gw $OLDGW
route add -net 183.172.0.0/14 gw $OLDGW
route add -net 183.182.0.0/19 gw $OLDGW
route add -net 183.184.0.0/13 gw $OLDGW
route add -net 183.192.0.0/10 gw $OLDGW
route add -net 192.83.122.0/24 gw $OLDGW
route add -net 192.83.169.0/24 gw $OLDGW
route add -net 192.124.154.0/24 gw $OLDGW
route add -net 192.188.170.0/24 gw $OLDGW
route add -net 198.17.7.0/24 gw $OLDGW
route add -net 202.0.110.0/24 gw $OLDGW
route add -net 202.0.176.0/22 gw $OLDGW
route add -net 202.4.128.0/19 gw $OLDGW
route add -net 202.4.252.0/22 gw $OLDGW
route add -net 202.8.128.0/19 gw $OLDGW
route add -net 202.10.64.0/20 gw $OLDGW
route add -net 202.14.88.0/24 gw $OLDGW
route add -net 202.14.235.0/24 gw $OLDGW
route add -net 202.14.236.0/23 gw $OLDGW
route add -net 202.14.238.0/24 gw $OLDGW
route add -net 202.20.120.0/24 gw $OLDGW
route add -net 202.22.248.0/21 gw $OLDGW
route add -net 202.38.0.0/20 gw $OLDGW
route add -net 202.38.64.0/18 gw $OLDGW
route add -net 202.38.128.0/21 gw $OLDGW
route add -net 202.38.136.0/23 gw $OLDGW
route add -net 202.38.138.0/24 gw $OLDGW
route add -net 202.38.140.0/22 gw $OLDGW
route add -net 202.38.144.0/22 gw $OLDGW
route add -net 202.38.149.0/24 gw $OLDGW
route add -net 202.38.150.0/23 gw $OLDGW
route add -net 202.38.152.0/22 gw $OLDGW
route add -net 202.38.156.0/24 gw $OLDGW
route add -net 202.38.158.0/23 gw $OLDGW
route add -net 202.38.160.0/23 gw $OLDGW
route add -net 202.38.164.0/22 gw $OLDGW
route add -net 202.38.168.0/21 gw $OLDGW
route add -net 202.38.176.0/23 gw $OLDGW
route add -net 202.38.184.0/21 gw $OLDGW
route add -net 202.38.192.0/18 gw $OLDGW
route add -net 202.41.152.0/21 gw $OLDGW
route add -net 202.41.240.0/20 gw $OLDGW
route add -net 202.43.76.0/22 gw $OLDGW
route add -net 202.43.144.0/20 gw $OLDGW
route add -net 202.46.32.0/19 gw $OLDGW
route add -net 202.46.224.0/20 gw $OLDGW
route add -net 202.60.112.0/20 gw $OLDGW
route add -net 202.63.248.0/22 gw $OLDGW
route add -net 202.69.4.0/22 gw $OLDGW
route add -net 202.69.16.0/20 gw $OLDGW
route add -net 202.70.0.0/19 gw $OLDGW
route add -net 202.74.8.0/21 gw $OLDGW
route add -net 202.75.208.0/20 gw $OLDGW
route add -net 202.85.208.0/20 gw $OLDGW
route add -net 202.90.0.0/22 gw $OLDGW
route add -net 202.90.224.0/20 gw $OLDGW
route add -net 202.90.252.0/22 gw $OLDGW
route add -net 202.91.0.0/22 gw $OLDGW
route add -net 202.91.128.0/22 gw $OLDGW
route add -net 202.91.176.0/20 gw $OLDGW
route add -net 202.91.224.0/19 gw $OLDGW
route add -net 202.92.0.0/22 gw $OLDGW
route add -net 202.92.252.0/22 gw $OLDGW
route add -net 202.93.0.0/22 gw $OLDGW
route add -net 202.93.252.0/22 gw $OLDGW
route add -net 202.94.0.0/19 gw $OLDGW
route add -net 202.95.0.0/19 gw $OLDGW
route add -net 202.95.252.0/22 gw $OLDGW
route add -net 202.96.0.0/12 gw $OLDGW
route add -net 202.112.0.0/13 gw $OLDGW
route add -net 202.120.0.0/15 gw $OLDGW
route add -net 202.122.0.0/21 gw $OLDGW
route add -net 202.122.32.0/21 gw $OLDGW
route add -net 202.122.64.0/19 gw $OLDGW
route add -net 202.122.112.0/21 gw $OLDGW
route add -net 202.122.128.0/24 gw $OLDGW
route add -net 202.123.96.0/20 gw $OLDGW
route add -net 202.124.24.0/22 gw $OLDGW
route add -net 202.125.176.0/20 gw $OLDGW
route add -net 202.127.0.0/21 gw $OLDGW
route add -net 202.127.12.0/22 gw $OLDGW
route add -net 202.127.16.0/20 gw $OLDGW
route add -net 202.127.40.0/21 gw $OLDGW
route add -net 202.127.48.0/20 gw $OLDGW
route add -net 202.127.112.0/20 gw $OLDGW
route add -net 202.127.128.0/19 gw $OLDGW
route add -net 202.127.160.0/21 gw $OLDGW
route add -net 202.127.192.0/20 gw $OLDGW
route add -net 202.127.208.0/22 gw $OLDGW
route add -net 202.127.216.0/21 gw $OLDGW
route add -net 202.127.224.0/19 gw $OLDGW
route add -net 202.130.0.0/19 gw $OLDGW
route add -net 202.130.224.0/19 gw $OLDGW
route add -net 202.131.16.0/21 gw $OLDGW
route add -net 202.131.48.0/20 gw $OLDGW
route add -net 202.131.208.0/20 gw $OLDGW
route add -net 202.136.48.0/20 gw $OLDGW
route add -net 202.136.208.0/20 gw $OLDGW
route add -net 202.136.224.0/20 gw $OLDGW
route add -net 202.136.252.0/22 gw $OLDGW
route add -net 202.141.160.0/19 gw $OLDGW
route add -net 202.142.16.0/20 gw $OLDGW
route add -net 202.143.16.0/20 gw $OLDGW
route add -net 202.148.96.0/19 gw $OLDGW
route add -net 202.149.160.0/19 gw $OLDGW
route add -net 202.149.224.0/19 gw $OLDGW
route add -net 202.150.16.0/20 gw $OLDGW
route add -net 202.152.176.0/20 gw $OLDGW
route add -net 202.153.48.0/20 gw $OLDGW
route add -net 202.158.160.0/19 gw $OLDGW
route add -net 202.160.176.0/20 gw $OLDGW
route add -net 202.164.0.0/20 gw $OLDGW
route add -net 202.164.25.0/24 gw $OLDGW
route add -net 202.165.96.0/20 gw $OLDGW
route add -net 202.165.176.0/20 gw $OLDGW
route add -net 202.165.208.0/20 gw $OLDGW
route add -net 202.168.160.0/19 gw $OLDGW
route add -net 202.170.128.0/19 gw $OLDGW
route add -net 202.170.216.0/21 gw $OLDGW
route add -net 202.173.8.0/21 gw $OLDGW
route add -net 202.173.224.0/19 gw $OLDGW
route add -net 202.179.240.0/20 gw $OLDGW
route add -net 202.180.128.0/19 gw $OLDGW
route add -net 202.181.112.0/20 gw $OLDGW
route add -net 202.189.80.0/20 gw $OLDGW
route add -net 202.192.0.0/12 gw $OLDGW
route add -net 203.18.50.0/24 gw $OLDGW
route add -net 203.78.48.0/20 gw $OLDGW
route add -net 203.79.0.0/20 gw $OLDGW
route add -net 203.80.144.0/20 gw $OLDGW
route add -net 203.81.16.0/20 gw $OLDGW
route add -net 203.83.56.0/21 gw $OLDGW
route add -net 203.86.0.0/18 gw $OLDGW
route add -net 203.86.64.0/19 gw $OLDGW
route add -net 203.88.32.0/19 gw $OLDGW
route add -net 203.88.192.0/19 gw $OLDGW
route add -net 203.89.0.0/22 gw $OLDGW
route add -net 203.90.0.0/22 gw $OLDGW
route add -net 203.90.128.0/18 gw $OLDGW
route add -net 203.90.192.0/19 gw $OLDGW
route add -net 203.91.32.0/19 gw $OLDGW
route add -net 203.91.96.0/20 gw $OLDGW
route add -net 203.91.120.0/21 gw $OLDGW
route add -net 203.92.0.0/22 gw $OLDGW
route add -net 203.92.160.0/19 gw $OLDGW
route add -net 203.93.0.0/16 gw $OLDGW
route add -net 203.94.0.0/19 gw $OLDGW
route add -net 203.95.0.0/21 gw $OLDGW
route add -net 203.95.96.0/19 gw $OLDGW
route add -net 203.99.16.0/20 gw $OLDGW
route add -net 203.99.80.0/20 gw $OLDGW
route add -net 203.100.32.0/20 gw $OLDGW
route add -net 203.100.80.0/20 gw $OLDGW
route add -net 203.100.96.0/19 gw $OLDGW
route add -net 203.100.192.0/20 gw $OLDGW
route add -net 203.110.160.0/19 gw $OLDGW
route add -net 203.114.244.0/22 gw $OLDGW
route add -net 203.118.192.0/19 gw $OLDGW
route add -net 203.118.248.0/22 gw $OLDGW
route add -net 203.119.24.0/21 gw $OLDGW
route add -net 203.119.32.0/22 gw $OLDGW
route add -net 203.119.80.0/22 gw $OLDGW
route add -net 203.128.32.0/19 gw $OLDGW
route add -net 203.128.96.0/19 gw $OLDGW
route add -net 203.128.128.0/19 gw $OLDGW
route add -net 203.130.32.0/19 gw $OLDGW
route add -net 203.132.32.0/19 gw $OLDGW
route add -net 203.134.240.0/21 gw $OLDGW
route add -net 203.135.96.0/19 gw $OLDGW
route add -net 203.135.160.0/20 gw $OLDGW
route add -net 203.142.219.0/24 gw $OLDGW
route add -net 203.148.0.0/18 gw $OLDGW
route add -net 203.152.64.0/19 gw $OLDGW
route add -net 203.156.192.0/18 gw $OLDGW
route add -net 203.158.16.0/21 gw $OLDGW
route add -net 203.161.180.0/24 gw $OLDGW
route add -net 203.161.192.0/19 gw $OLDGW
route add -net 203.166.160.0/19 gw $OLDGW
route add -net 203.171.224.0/20 gw $OLDGW
route add -net 203.174.7.0/24 gw $OLDGW
route add -net 203.174.96.0/19 gw $OLDGW
route add -net 203.175.128.0/19 gw $OLDGW
route add -net 203.175.192.0/18 gw $OLDGW
route add -net 203.176.168.0/21 gw $OLDGW
route add -net 203.184.80.0/20 gw $OLDGW
route add -net 203.187.160.0/19 gw $OLDGW
route add -net 203.190.96.0/20 gw $OLDGW
route add -net 203.191.16.0/20 gw $OLDGW
route add -net 203.191.64.0/18 gw $OLDGW
route add -net 203.191.144.0/20 gw $OLDGW
route add -net 203.192.0.0/19 gw $OLDGW
route add -net 203.196.0.0/21 gw $OLDGW
route add -net 203.207.64.0/18 gw $OLDGW
route add -net 203.207.128.0/17 gw $OLDGW
route add -net 203.208.0.0/20 gw $OLDGW
route add -net 203.208.16.0/22 gw $OLDGW
route add -net 203.208.32.0/19 gw $OLDGW
route add -net 203.209.224.0/19 gw $OLDGW
route add -net 203.212.0.0/20 gw $OLDGW
route add -net 203.212.80.0/20 gw $OLDGW
route add -net 203.222.192.0/20 gw $OLDGW
route add -net 203.223.0.0/20 gw $OLDGW
route add -net 210.2.0.0/19 gw $OLDGW
route add -net 210.5.0.0/19 gw $OLDGW
route add -net 210.5.128.0/19 gw $OLDGW
route add -net 210.12.0.0/15 gw $OLDGW
route add -net 210.14.64.0/19 gw $OLDGW
route add -net 210.14.112.0/20 gw $OLDGW
route add -net 210.14.128.0/17 gw $OLDGW
route add -net 210.15.0.0/17 gw $OLDGW
route add -net 210.15.128.0/18 gw $OLDGW
route add -net 210.16.128.0/18 gw $OLDGW
route add -net 210.21.0.0/16 gw $OLDGW
route add -net 210.22.0.0/16 gw $OLDGW
route add -net 210.23.32.0/19 gw $OLDGW
route add -net 210.25.0.0/16 gw $OLDGW
route add -net 210.26.0.0/15 gw $OLDGW
route add -net 210.28.0.0/14 gw $OLDGW
route add -net 210.32.0.0/12 gw $OLDGW
route add -net 210.51.0.0/16 gw $OLDGW
route add -net 210.52.0.0/15 gw $OLDGW
route add -net 210.56.192.0/19 gw $OLDGW
route add -net 210.72.0.0/14 gw $OLDGW
route add -net 210.76.0.0/15 gw $OLDGW
route add -net 210.78.0.0/16 gw $OLDGW
route add -net 210.79.64.0/18 gw $OLDGW
route add -net 210.79.224.0/19 gw $OLDGW
route add -net 210.82.0.0/15 gw $OLDGW
route add -net 210.87.128.0/18 gw $OLDGW
route add -net 210.185.192.0/18 gw $OLDGW
route add -net 210.192.96.0/19 gw $OLDGW
route add -net 210.211.0.0/20 gw $OLDGW
route add -net 211.64.0.0/13 gw $OLDGW
route add -net 211.80.0.0/12 gw $OLDGW
route add -net 211.96.0.0/13 gw $OLDGW
route add -net 211.136.0.0/13 gw $OLDGW
route add -net 211.144.0.0/12 gw $OLDGW
route add -net 211.160.0.0/13 gw $OLDGW
route add -net 218.0.0.0/11 gw $OLDGW
route add -net 218.56.0.0/13 gw $OLDGW
route add -net 218.64.0.0/11 gw $OLDGW
route add -net 218.96.0.0/14 gw $OLDGW
route add -net 218.104.0.0/14 gw $OLDGW
route add -net 218.108.0.0/15 gw $OLDGW
route add -net 218.185.192.0/19 gw $OLDGW
route add -net 218.192.0.0/12 gw $OLDGW
route add -net 218.240.0.0/13 gw $OLDGW
route add -net 218.249.0.0/16 gw $OLDGW
route add -net 219.72.0.0/16 gw $OLDGW
route add -net 219.82.0.0/16 gw $OLDGW
route add -net 219.128.0.0/11 gw $OLDGW
route add -net 219.216.0.0/13 gw $OLDGW
route add -net 219.224.0.0/12 gw $OLDGW
route add -net 219.242.0.0/15 gw $OLDGW
route add -net 219.244.0.0/14 gw $OLDGW
route add -net 220.101.192.0/18 gw $OLDGW
route add -net 220.112.0.0/14 gw $OLDGW
route add -net 220.152.128.0/17 gw $OLDGW
route add -net 220.154.0.0/15 gw $OLDGW
route add -net 220.160.0.0/11 gw $OLDGW
route add -net 220.192.0.0/12 gw $OLDGW
route add -net 220.231.0.0/18 gw $OLDGW
route add -net 220.231.128.0/17 gw $OLDGW
route add -net 220.232.64.0/18 gw $OLDGW
route add -net 220.234.0.0/16 gw $OLDGW
route add -net 220.242.0.0/15 gw $OLDGW
route add -net 220.248.0.0/14 gw $OLDGW
route add -net 220.252.0.0/16 gw $OLDGW
route add -net 221.0.0.0/13 gw $OLDGW
route add -net 221.8.0.0/14 gw $OLDGW
route add -net 221.12.0.0/17 gw $OLDGW
route add -net 221.12.128.0/18 gw $OLDGW
route add -net 221.13.0.0/16 gw $OLDGW
route add -net 221.14.0.0/15 gw $OLDGW
route add -net 221.122.0.0/15 gw $OLDGW
route add -net 221.129.0.0/16 gw $OLDGW
route add -net 221.130.0.0/15 gw $OLDGW
route add -net 221.133.224.0/19 gw $OLDGW
route add -net 221.136.0.0/15 gw $OLDGW
route add -net 221.172.0.0/14 gw $OLDGW
route add -net 221.176.0.0/13 gw $OLDGW
route add -net 221.192.0.0/14 gw $OLDGW
route add -net 221.196.0.0/15 gw $OLDGW
route add -net 221.198.0.0/16 gw $OLDGW
route add -net 221.199.0.0/17 gw $OLDGW
route add -net 221.199.128.0/18 gw $OLDGW
route add -net 221.199.192.0/20 gw $OLDGW
route add -net 221.199.224.0/19 gw $OLDGW
route add -net 221.200.0.0/13 gw $OLDGW
route add -net 221.208.0.0/12 gw $OLDGW
route add -net 221.224.0.0/12 gw $OLDGW
route add -net 222.16.0.0/12 gw $OLDGW
route add -net 222.32.0.0/11 gw $OLDGW
route add -net 222.64.0.0/11 gw $OLDGW
route add -net 222.125.0.0/16 gw $OLDGW
route add -net 222.126.128.0/17 gw $OLDGW
route add -net 222.128.0.0/12 gw $OLDGW
route add -net 222.160.0.0/14 gw $OLDGW
route add -net 222.168.0.0/13 gw $OLDGW
route add -net 222.176.0.0/12 gw $OLDGW
route add -net 222.192.0.0/11 gw $OLDGW
route add -net 222.240.0.0/13 gw $OLDGW
route add -net 222.248.0.0/15 gw $OLDGW
route add -net 223.2.0.0/15 gw $OLDGW
route add -net 223.4.0.0/14 gw $OLDGW
route add -net 223.8.0.0/13 gw $OLDGW
route add -net 223.20.0.0/15 gw $OLDGW
route add -net 223.64.0.0/10 gw $OLDGW
route add -net 223.128.0.0/15 gw $OLDGW
route add -net 223.160.0.0/14 gw $OLDGW
route add -net 223.166.0.0/15 gw $OLDGW
route add -net 223.192.0.0/15 gw $OLDGW
route add -net 223.198.0.0/15 gw $OLDGW
route add -net 223.201.0.0/16 gw $OLDGW
route add -net 223.202.0.0/15 gw $OLDGW
route add -net 223.208.0.0/13 gw $OLDGW
route add -net 223.220.0.0/15 gw $OLDGW
route add -net 223.223.176.0/20 gw $OLDGW
route add -net 223.223.192.0/20 gw $OLDGW
route add -net 223.240.0.0/13 gw $OLDGW
route add -net 223.248.0.0/14 gw $OLDGW
route add -net 223.254.0.0/16 gw $OLDGW
route add -net 223.255.0.0/17 gw $OLDGW
route add -net 27.8.0.0/13 gw $OLDGW
route add -net 27.16.0.0/12 gw $OLDGW
route add -net 27.36.0.0/14 gw $OLDGW
route add -net 27.40.0.0/13 gw $OLDGW
route add -net 27.50.128.0/17 gw $OLDGW
route add -net 27.54.192.0/18 gw $OLDGW
route add -net 27.98.208.0/20 gw $OLDGW
route add -net 27.98.224.0/19 gw $OLDGW
route add -net 27.100.36.0/22 gw $OLDGW
route add -net 27.103.0.0/16 gw $OLDGW
route add -net 27.106.128.0/18 gw $OLDGW
route add -net 27.112.0.0/18 gw $OLDGW
route add -net 27.112.80.0/20 gw $OLDGW
route add -net 27.113.128.0/18 gw $OLDGW
route add -net 27.115.0.0/17 gw $OLDGW
route add -net 27.116.44.0/22 gw $OLDGW
route add -net 27.128.0.0/15 gw $OLDGW
route add -net 27.131.220.0/22 gw $OLDGW
route add -net 27.144.0.0/16 gw $OLDGW
route add -net 27.148.0.0/14 gw $OLDGW
route add -net 27.152.0.0/13 gw $OLDGW
route add -net 27.184.0.0/13 gw $OLDGW
route add -net 27.192.0.0/11 gw $OLDGW
route add -net 27.224.0.0/14 gw $OLDGW
route add -net 58.14.0.0/15 gw $OLDGW
route add -net 58.16.0.0/13 gw $OLDGW
route add -net 58.24.0.0/15 gw $OLDGW
route add -net 58.30.0.0/15 gw $OLDGW
route add -net 58.32.0.0/11 gw $OLDGW
route add -net 58.66.0.0/15 gw $OLDGW
route add -net 58.68.128.0/17 gw $OLDGW
route add -net 58.82.0.0/15 gw $OLDGW
route add -net 58.87.64.0/18 gw $OLDGW
route add -net 58.99.128.0/17 gw $OLDGW
route add -net 58.100.0.0/15 gw $OLDGW
route add -net 58.116.0.0/14 gw $OLDGW
route add -net 58.128.0.0/13 gw $OLDGW
route add -net 58.144.0.0/16 gw $OLDGW
route add -net 58.154.0.0/15 gw $OLDGW
route add -net 58.192.0.0/11 gw $OLDGW
route add -net 58.240.0.0/12 gw $OLDGW
route add -net 59.32.0.0/11 gw $OLDGW
route add -net 59.64.0.0/12 gw $OLDGW
route add -net 59.80.0.0/14 gw $OLDGW
route add -net 59.107.0.0/16 gw $OLDGW
route add -net 59.108.0.0/14 gw $OLDGW
route add -net 59.151.0.0/17 gw $OLDGW
route add -net 59.155.0.0/16 gw $OLDGW
route add -net 59.172.0.0/14 gw $OLDGW
route add -net 59.191.0.0/17 gw $OLDGW
route add -net 59.191.240.0/20 gw $OLDGW
route add -net 59.192.0.0/10 gw $OLDGW
route add -net 60.0.0.0/11 gw $OLDGW
route add -net 60.55.0.0/16 gw $OLDGW
route add -net 60.63.0.0/16 gw $OLDGW
route add -net 60.160.0.0/11 gw $OLDGW
route add -net 60.194.0.0/15 gw $OLDGW
route add -net 60.200.0.0/13 gw $OLDGW
route add -net 60.208.0.0/12 gw $OLDGW
route add -net 60.232.0.0/15 gw $OLDGW
route add -net 60.235.0.0/16 gw $OLDGW
route add -net 60.245.128.0/17 gw $OLDGW
route add -net 60.247.0.0/16 gw $OLDGW
route add -net 60.252.0.0/16 gw $OLDGW
route add -net 60.253.128.0/17 gw $OLDGW
route add -net 60.255.0.0/16 gw $OLDGW
route add -net 61.4.64.0/19 gw $OLDGW
route add -net 61.4.176.0/20 gw $OLDGW
route add -net 61.8.160.0/20 gw $OLDGW
route add -net 61.28.0.0/17 gw $OLDGW
route add -net 61.29.128.0/17 gw $OLDGW
route add -net 61.45.128.0/18 gw $OLDGW
route add -net 61.47.128.0/18 gw $OLDGW
route add -net 61.48.0.0/13 gw $OLDGW
route add -net 61.87.192.0/18 gw $OLDGW
route add -net 61.128.0.0/10 gw $OLDGW
route add -net 61.232.0.0/14 gw $OLDGW
route add -net 61.236.0.0/15 gw $OLDGW
route add -net 61.240.0.0/14 gw $OLDGW
##### end batch route #####


# prepare for the exceptional routes, see http://code.google.com/p/autoddvpn/issues/detail?id=7
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") preparing the exceptional routes" >> $LOG
if [ $(nvram get exroute_enable) -eq 1 ]; then
	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") modifying the exceptional routes" >> $LOG
	if [ ! -d $EXROUTEDIR ]; then
		EXROUTEDIR='/tmp/exroute.d'
		mkdir $EXROUTEDIR
	fi
	for i in $(nvram get exroute_list)
	do
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") fetching exceptional routes for $i"  >> $LOG
		if [ -d $EXROUTEDIR -a ! -f $EXROUTEDIR/$i ]; then
			echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") missing $EXROUTEDIR/$i, wget it now."  >> $LOG
			wget http://autoddvpn.googlecode.com/svn/trunk/exroute.d/$i -O $EXROUTEDIR/$i 
		fi
		if [ ! -f $EXROUTEDIR/$i ]; then
			echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") $EXROUTEDIR/$i not found, skip."  >> $LOG
			continue
		fi
		for r in $(grep -v ^# $EXROUTEDIR/$i)
		do
			echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") adding $r via wan_gateway"  >> $LOG
			# check the item is a subnet or a single ip address
			echo $r | grep "/" > /dev/null
			if [ $? -eq 0 ]; then
				route add -net $r gw $(nvram get wan_gateway) 
			else
				route add $r gw $(nvram get wan_gateway) 
			fi
		done 
	done
	#route | grep ^default | awk '{print $2}' >> $LOG
	# for custom list of exceptional routes
	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") modifying custom exceptional routes if available" >> $LOG
	for i in $(nvram get exroute_custom)
	do
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") adding custom host/subnet $i via wan_gateway"  >> $LOG
		# check the item is a subnet or a single ip address
		echo $i | grep "/" > /dev/null
		if [ $? -eq 0 ]; then
			route add -net $i gw $(nvram get wan_gateway) 
		else
			route add $i gw $(nvram get wan_gateway) 
		fi
	done
else
	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") exceptional routes disabled."  >> $LOG
	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") exceptional routes features detail:  http://goo.gl/fYfJ"  >> $LOG
fi

# final check again
echo "$INFO final check the default gw"
while true
do
	GW=$(route -n | grep ^0.0.0.0 | awk '{print $2}')
	echo "$DEBUG my current gw is $GW"
	#route | grep ^default | awk '{print $2}'
	if [ "$GW" == "$OLDGW" ]; then 
		echo "$DEBUG still got the OLDGW, why?"
		echo "$INFO delete default gw $OLDGW" 
		route del default gw $OLDGW
		echo "$INFO add default gw $VPNGW again" 
		route add default gw $VPNGW
		sleep 3
	else
		break
	fi
done

echo "$INFO static routes added"
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpnup.sh ended" >> $LOG
# release the lock
rm -f $LOCK
