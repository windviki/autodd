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
				echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") router type: tomato" >> $LOG
				VPNSRV=$(nvram get pptpd_client_srvip)
				VPNSRVSUB=$(nvram get pptpd_client_srvsub)
				PPTPDEV=$(nvram get pptp_client_iface)
				VPNGW=$(nvram get pptp_client_gateway)
				;;
			*)
				# assume it to be a DD-WRT
				echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") router type: DD-WRT" >> $LOG
				VPNSRV=$(nvram get pptpd_client_srvip)
				VPNSRVSUB=$(nvram get pptpd_client_srvsub)
				PPTPDEV=$(route -n | grep ^$VPNSRVSUB | awk '{print $NF}')
				VPNGW=$(ifconfig $PPTPDEV | grep -Eo "P-t-P:([0-9.]+)" | cut -d: -f2)
				VPNUPCUSTOM='/jffs/pptp/vpnup_custom' 
				;;
		esac
		;;
	"openvpn")
		VPNSRV=$(nvram get openvpncl_remoteip)
		#OPENVPNSRVSUB=$(nvram get OPENVPNd_client_srvsub)
		#OPENVPNDEV=$(route | grep ^$OPENVPNSRVSUB | awk '{print $NF}')
		OPENVPNDEV='tun0'
		VPNGW=$(ifconfig $OPENVPNDEV | grep -Eo "P-t-P:([0-9.]+)" | cut -d: -f2)
		VPNUPCUSTOM='/jffs/openvpn/vpnup_custom'
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

#route add -host $VPNSRV gw $OLDGW
#echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") delete default gw $OLDGW"  >> $LOG
#route del default gw $OLDGW

#echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") add default gw $VPNGW"  >> $LOG
#route add default gw $VPNGW

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") loading vpnup_custom if available" >> $LOG
export VPNGW=$VPNGW
export OLDGW=$OLDGW
grep ^route $VPNUPCUSTOM  | /bin/sh -x

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") adding the static routes, this may take a while." >> $LOG

##### begin batch route #####
# Google DNS and OpenDNS
route add -host 8.8.8.8 gw $VPNGW
route add -host 8.8.4.4 gw $VPNGW
route add -host 208.67.222.222 gw $VPNGW
# www.dropbox.com
route add -host 174.36.30.70 gw $VPNGW
# wiki.dropbox.com
route add -host 174.36.51.41 gw $VPNGW
# login.facebook.com
#route add -net 66.220.147.0/24 gw $VPNGW
#route add -net 66.220.146.0/24 gw $VPNGW
# for Google
route add -net 72.14.192.0/18 gw $VPNGW
route add -net 74.125.0.0/16 gw $VPNGW
# static.cache.l.google.com in Taiwan
route add -net 60.199.175.0/24 gw $VPNGW
# for all facebook
route add -net 66.220.0.0/16 gw $VPNGW
route add -net 69.63.0.0/16 gw $VPNGW
# fbcdn
route add -net 96.17.8.0/24 gw $VPNGW
# imgN.imageshack.us
route add -net 208.75.252.0/24 gw $VPNGW
route add -net 208.94.3.0/24 gw $VPNGW                                                            
route add -net 38.99.77.0/24 gw $VPNGW  
route add -net 38.99.76.0/24 gw $VPNGW  
# tw.nextmedia.com
route add -host 210.242.234.140 gw $VPNGW
# {www|api}.twitter.com
route add -net 168.143.162.0/24 gw $VPNGW
route add -net 168.143.171.0/24 gw $VPNGW
route add -net 128.242.240.0/24 gw $VPNGW
route add -net 128.242.245.0/24 gw $VPNGW
route add -net 128.242.250.0/24 gw $VPNGW
# tw.rd.yahoo.com
route add -net 203.84.203.0/24 gw $VPNGW
# tw.blog.yahoo
route add -net 203.84.202.0/24 gw $VPNGW
# for all TW Yahoo
route add -net 116.214.0.0/16 gw $VPNGW
# yam.com
route add -net 60.199.252.0/24 gw $VPNGW
# c.youtube.com
#route add -net 74.125.164.0/24 gw $VPNGW
# ytimg.com
#route add -net 74.125.6.0/24 gw $VPNGW
#route add -net 74.125.15.0/24 gw $VPNGW
#route add -net 74.125.19.0/24 gw $VPNGW
# for all youtube
route add -net 66.102.0.0/20 gw $VPNGW
route add -net 72.14.213.0/24 gw $VPNGW
# for vimeo
# av.vimeo.com
route add -net 117.104.138.0/24 gw $VPNGW
route add -net 24.143.203.0/24 gw $VPNGW
route add -net 198.173.160.0/24 gw $VPNGW
route add -net 198.173.161.0/24 gw $VPNGW
# assets.vimeo.com
route add -net 124.40.51.0/24 gw $VPNGW
# *.vimeo.com
route add -net 66.235.126.0/24 gw $VPNGW
#route add -net 74.125.0.0/16 gw $VPNGW
route add -net 173.194.0.0/16 gw $VPNGW
route add -net 208.117.224.0/19 gw $VPNGW
route add -net 64.233.160.0/19 gw $VPNGW
# for all xuite
route add -net 210.242.17.0/24 gw $VPNGW
route add -net 210.242.18.0/24 gw $VPNGW
# www.books.com.tw
route add -net 61.31.206.0/24 gw $VPNGW
route add -net 58.86.40.0/24 gw $VPNGW
# all others
route add -host 109.104.79.84 gw $VPNGW
route add -host 109.239.51.251 gw $VPNGW
route add -host 109.239.54.15 gw $VPNGW
route add -host 109.74.206.5 gw $VPNGW
route add -host 111.92.237.110 gw $VPNGW
route add -host 112.140.185.153 gw $VPNGW
route add -host 112.78.199.213 gw $VPNGW
route add -host 113.105.171.180 gw $VPNGW
route add -host 113.28.60.58 gw $VPNGW
route add -host 114.141.199.247 gw $VPNGW
route add -host 114.142.146.69 gw $VPNGW
route add -host 114.32.90.158 gw $VPNGW
route add -host 114.80.210.217 gw $VPNGW
route add -host 116.214.13.16 gw $VPNGW
route add -host 118.142.13.39 gw $VPNGW
route add -host 118.142.27.186 gw $VPNGW
route add -host 118.142.39.198 gw $VPNGW
route add -host 118.142.53.179 gw $VPNGW
route add -host 118.144.83.112 gw $VPNGW
route add -host 118.173.204.2 gw $VPNGW
route add -host 118.215.4.79 gw $VPNGW
route add -host 119.246.200.195 gw $VPNGW
route add -host 119.246.26.17 gw $VPNGW
route add -host 119.247.151.166 gw $VPNGW
route add -host 119.247.82.64 gw $VPNGW
route add -host 12.69.32.110 gw $VPNGW
route add -host 121.127.233.45 gw $VPNGW
route add -host 121.254.154.237 gw $VPNGW
route add -host 121.54.174.111 gw $VPNGW
route add -host 122.152.128.121 gw $VPNGW
route add -host 122.209.125.55 gw $VPNGW
route add -host 122.252.61.50 gw $VPNGW
route add -host 123.204.64.217 gw $VPNGW
route add -host 124.244.150.251 gw $VPNGW
route add -host 125.29.60.4 gw $VPNGW
route add -host 127.0.0.1 gw $VPNGW
route add -host 128.100.171.12 gw $VPNGW
route add -host 128.242.240.116 gw $VPNGW
route add -host 14.136.32.79 gw $VPNGW
route add -host 140.109.29.253 gw $VPNGW
route add -host 140.113.121.211 gw $VPNGW
route add -host 140.130.111.209 gw $VPNGW
route add -host 146.82.200.125 gw $VPNGW
route add -host 163.29.3.40 gw $VPNGW
route add -host 168.143.113.10 gw $VPNGW
route add -host 168.143.162.52 gw $VPNGW
route add -host 169.207.67.17 gw $VPNGW
route add -host 170.140.52.142 gw $VPNGW
route add -host 170.140.53.44 gw $VPNGW
route add -host 173.13.167.171 gw $VPNGW
route add -host 173.192.129.139 gw $VPNGW
route add -host 173.201.141.91 gw $VPNGW
route add -host 173.201.149.208 gw $VPNGW
route add -host 173.201.216.46 gw $VPNGW
route add -host 173.201.253.37 gw $VPNGW
route add -host 173.201.37.86 gw $VPNGW
route add -host 173.201.78.203 gw $VPNGW
route add -host 173.201.96.224 gw $VPNGW
route add -host 173.203.217.152 gw $VPNGW
route add -host 173.203.238.64 gw $VPNGW
route add -host 173.205.125.108 gw $VPNGW
route add -host 173.208.164.222 gw $VPNGW
route add -host 173.212.249.205 gw $VPNGW
route add -host 173.224.209.173 gw $VPNGW
route add -host 173.224.213.32 gw $VPNGW
route add -host 173.224.215.229 gw $VPNGW
route add -host 173.224.216.175 gw $VPNGW
route add -host 173.230.151.37 gw $VPNGW
route add -host 173.230.152.30 gw $VPNGW
route add -host 173.230.156.6 gw $VPNGW
route add -host 173.231.13.162 gw $VPNGW
route add -host 173.231.9.226 gw $VPNGW
route add -host 173.236.130.33 gw $VPNGW
route add -host 173.236.162.231 gw $VPNGW
route add -host 173.236.180.94 gw $VPNGW
route add -host 173.236.243.189 gw $VPNGW
route add -host 173.236.27.154 gw $VPNGW
route add -host 173.244.193.127 gw $VPNGW
route add -host 173.255.214.42 gw $VPNGW
route add -host 173.3.200.32 gw $VPNGW
route add -host 173.45.226.29 gw $VPNGW
route add -host 173.83.74.51 gw $VPNGW
route add -host 174.120.129.190 gw $VPNGW
route add -host 174.120.180.226 gw $VPNGW
route add -host 174.120.189.254 gw $VPNGW
route add -host 174.120.8.253 gw $VPNGW
route add -host 174.121.180.210 gw $VPNGW
route add -host 174.121.79.136 gw $VPNGW
route add -host 174.122.130.244 gw $VPNGW
route add -host 174.122.246.123 gw $VPNGW
route add -host 174.123.203.58 gw $VPNGW
route add -host 174.123.219.136 gw $VPNGW
route add -host 174.129.1.157 gw $VPNGW
route add -host 174.129.182.241 gw $VPNGW
route add -host 174.129.227.239 gw $VPNGW
route add -host 174.129.228.246 gw $VPNGW
route add -host 174.129.247.225 gw $VPNGW
route add -host 174.129.249.253 gw $VPNGW
route add -host 174.129.32.46 gw $VPNGW
route add -host 174.132.147.60 gw $VPNGW
route add -host 174.132.150.194 gw $VPNGW
route add -host 174.132.186.206 gw $VPNGW
route add -host 174.132.96.140 gw $VPNGW
route add -host 174.133.14.74 gw $VPNGW
route add -host 174.133.217.98 gw $VPNGW
route add -host 174.133.64.220 gw $VPNGW
route add -host 174.138.171.118 gw $VPNGW
route add -host 174.142.114.102 gw $VPNGW
route add -host 174.143.157.148 gw $VPNGW
route add -host 174.143.243.139 gw $VPNGW
route add -host 174.143.45.104 gw $VPNGW
route add -host 174.35.52.131 gw $VPNGW
route add -host 174.36.125.82 gw $VPNGW
route add -host 174.36.186.208 gw $VPNGW
route add -host 174.36.196.242 gw $VPNGW
route add -host 174.36.228.137 gw $VPNGW
route add -host 174.37.129.192 gw $VPNGW
route add -host 174.37.172.68 gw $VPNGW
route add -host 178.162.191.20 gw $VPNGW
route add -host 178.63.21.37 gw $VPNGW
route add -host 183.179.121.102 gw $VPNGW
route add -host 184.154.61.146 gw $VPNGW
route add -host 184.72.221.111 gw $VPNGW
route add -host 184.72.246.159 gw $VPNGW
route add -host 184.73.110.30 gw $VPNGW
route add -host 184.73.159.65 gw $VPNGW
route add -host 184.73.161.164 gw $VPNGW
route add -host 184.73.174.19 gw $VPNGW
route add -host 184.73.176.140 gw $VPNGW
route add -host 184.73.216.15 gw $VPNGW
route add -host 184.73.221.175 gw $VPNGW
route add -host 184.82.34.68 gw $VPNGW
route add -host 184.82.98.171 gw $VPNGW
route add -host 192.121.86.163 gw $VPNGW
route add -host 193.202.110.154 gw $VPNGW
route add -host 194.14.79.3 gw $VPNGW
route add -host 194.55.26.46 gw $VPNGW
route add -host 194.55.30.46 gw $VPNGW
route add -host 194.60.206.105 gw $VPNGW
route add -host 194.71.107.15 gw $VPNGW
route add -host 194.9.94.79 gw $VPNGW
route add -host 194.90.190.38 gw $VPNGW
route add -host 195.14.0.137 gw $VPNGW
route add -host 195.189.143.147 gw $VPNGW
route add -host 195.234.175.160 gw $VPNGW
route add -host 195.242.152.250 gw $VPNGW
route add -host 195.39.35.193 gw $VPNGW
route add -host 198.173.75.52 gw $VPNGW
route add -host 199.71.212.202 gw $VPNGW
route add -host 202.108.39.83 gw $VPNGW
route add -host 202.123.82.23 gw $VPNGW
route add -host 202.130.88.26 gw $VPNGW
route add -host 202.172.28.100 gw $VPNGW
route add -host 202.177.27.210 gw $VPNGW
route add -host 202.177.28.164 gw $VPNGW
route add -host 202.181.187.51 gw $VPNGW
route add -host 202.181.207.207 gw $VPNGW
route add -host 202.181.238.98 gw $VPNGW
route add -host 202.181.242.75 gw $VPNGW
route add -host 202.181.99.87 gw $VPNGW
route add -host 202.190.75.151 gw $VPNGW
route add -host 202.27.28.10 gw $VPNGW
route add -host 202.39.176.10 gw $VPNGW
route add -host 202.67.195.96 gw $VPNGW
route add -host 202.67.226.114 gw $VPNGW
route add -host 202.67.247.125 gw $VPNGW
route add -host 202.71.100.186 gw $VPNGW
route add -host 202.71.108.95 gw $VPNGW
route add -host 202.81.252.243 gw $VPNGW
route add -host 202.85.162.104 gw $VPNGW
route add -host 203.105.2.20 gw $VPNGW
route add -host 203.131.229.38 gw $VPNGW
route add -host 203.141.139.184 gw $VPNGW
route add -host 203.169.176.64 gw $VPNGW
route add -host 203.194.164.31 gw $VPNGW
route add -host 203.194.209.191 gw $VPNGW
route add -host 203.209.156.112 gw $VPNGW
route add -host 203.215.253.134 gw $VPNGW
route add -host 203.80.0.172 gw $VPNGW
route add -host 203.85.0.241 gw $VPNGW
route add -host 203.98.176.195 gw $VPNGW
route add -host 204.107.28.181 gw $VPNGW
route add -host 204.145.120.172 gw $VPNGW
route add -host 204.152.194.52 gw $VPNGW
route add -host 204.152.198.140 gw $VPNGW
route add -host 204.16.252.112 gw $VPNGW
route add -host 204.160.104.126 gw $VPNGW
route add -host 204.232.142.118 gw $VPNGW
route add -host 204.27.60.19 gw $VPNGW
route add -host 204.45.29.203 gw $VPNGW
route add -host 204.74.211.42 gw $VPNGW
route add -host 204.74.214.205 gw $VPNGW
route add -host 204.74.222.76 gw $VPNGW
route add -host 204.9.177.195 gw $VPNGW
route add -host 204.93.175.51 gw $VPNGW
route add -host 205.196.221.62 gw $VPNGW
route add -host 205.214.86.20 gw $VPNGW
route add -host 206.188.193.76 gw $VPNGW
route add -host 206.190.60.37 gw $VPNGW
route add -host 206.217.207.202 gw $VPNGW
route add -host 206.217.221.95 gw $VPNGW
route add -host 206.46.232.39 gw $VPNGW
route add -host 207.171.166.140 gw $VPNGW
route add -host 207.178.151.10 gw $VPNGW
route add -host 207.200.105.36 gw $VPNGW
route add -host 207.210.108.158 gw $VPNGW
route add -host 207.210.231.59 gw $VPNGW
route add -host 207.217.125.50 gw $VPNGW
route add -host 207.241.229.39 gw $VPNGW
route add -host 207.44.152.75 gw $VPNGW
route add -host 207.55.250.19 gw $VPNGW
route add -host 207.58.161.171 gw $VPNGW
route add -host 208.109.123.71 gw $VPNGW
route add -host 208.109.178.73 gw $VPNGW
route add -host 208.109.181.211 gw $VPNGW
route add -host 208.131.25.34 gw $VPNGW
route add -host 208.167.225.104 gw $VPNGW
route add -host 208.43.164.194 gw $VPNGW
route add -host 208.43.237.140 gw $VPNGW
route add -host 208.43.44.195 gw $VPNGW
route add -host 208.53.147.143 gw $VPNGW
route add -host 208.65.130.26 gw $VPNGW
route add -host 208.66.67.30 gw $VPNGW
route add -host 208.69.4.141 gw $VPNGW
route add -host 208.69.40.100 gw $VPNGW
route add -host 208.71.106.124 gw $VPNGW
route add -host 208.71.112.30 gw $VPNGW
route add -host 208.72.2.186 gw $VPNGW
route add -host 208.75.184.192 gw $VPNGW
route add -host 208.77.23.4 gw $VPNGW
route add -host 208.78.224.202 gw $VPNGW
route add -host 208.80.152.2 gw $VPNGW
route add -host 208.80.56.11 gw $VPNGW
route add -host 208.88.182.181 gw $VPNGW
route add -host 208.92.218.173 gw $VPNGW
route add -host 208.94.2.98 gw $VPNGW
route add -host 209.11.132.22 gw $VPNGW
route add -host 209.160.20.56 gw $VPNGW
route add -host 209.17.74.13 gw $VPNGW
route add -host 209.172.55.136 gw $VPNGW
route add -host 209.190.24.5 gw $VPNGW
route add -host 209.197.73.62 gw $VPNGW
route add -host 209.20.95.202 gw $VPNGW
route add -host 209.200.244.207 gw $VPNGW
route add -host 209.222.1.145 gw $VPNGW
route add -host 209.222.138.10 gw $VPNGW
route add -host 209.222.2.149 gw $VPNGW
route add -host 209.25.137.150 gw $VPNGW
route add -host 209.40.194.248 gw $VPNGW
route add -host 209.51.161.182 gw $VPNGW
route add -host 209.51.163.53 gw $VPNGW
route add -host 209.51.191.253 gw $VPNGW
route add -host 209.51.196.250 gw $VPNGW
route add -host 209.62.106.115 gw $VPNGW
route add -host 209.62.20.200 gw $VPNGW
route add -host 209.62.69.106 gw $VPNGW
route add -host 209.68.35.19 gw $VPNGW
route add -host 209.8.254.21 gw $VPNGW
route add -host 209.85.171.121 gw $VPNGW
route add -host 210.0.141.99 gw $VPNGW
route add -host 210.155.3.54 gw $VPNGW
route add -host 210.17.189.182 gw $VPNGW
route add -host 210.17.22.177 gw $VPNGW
route add -host 210.17.252.133 gw $VPNGW
route add -host 210.242.195.60 gw $VPNGW
route add -host 210.242.234.159 gw $VPNGW
route add -host 210.59.228.219 gw $VPNGW
route add -host 211.172.252.20 gw $VPNGW
route add -host 211.3.216.96 gw $VPNGW
route add -host 211.72.204.197 gw $VPNGW
route add -host 211.72.206.146 gw $VPNGW
route add -host 211.75.131.205 gw $VPNGW
route add -host 212.118.245.201 gw $VPNGW
route add -host 212.174.134.13 gw $VPNGW
route add -host 212.239.17.82 gw $VPNGW
route add -host 212.27.48.10 gw $VPNGW
route add -host 212.44.106.49 gw $VPNGW
route add -host 212.58.224.138 gw $VPNGW
route add -host 212.58.246.91 gw $VPNGW
route add -host 212.58.254.252 gw $VPNGW
route add -host 212.64.146.224 gw $VPNGW
route add -host 213.139.108.166 gw $VPNGW
route add -host 213.171.192.129 gw $VPNGW
route add -host 213.203.223.20 gw $VPNGW
route add -host 213.73.89.122 gw $VPNGW
route add -host 216.117.178.81 gw $VPNGW
route add -host 216.131.83.58 gw $VPNGW
route add -host 216.139.208.243 gw $VPNGW
route add -host 216.139.245.96 gw $VPNGW
route add -host 216.14.215.2 gw $VPNGW
route add -host 216.15.252.72 gw $VPNGW
route add -host 216.18.166.136 gw $VPNGW
route add -host 216.18.170.229 gw $VPNGW
route add -host 216.18.194.245 gw $VPNGW
route add -host 216.18.197.66 gw $VPNGW
route add -host 216.18.218.116 gw $VPNGW
route add -host 216.18.223.188 gw $VPNGW
route add -host 216.18.227.35 gw $VPNGW
route add -host 216.18.239.117 gw $VPNGW
route add -host 216.230.250.151 gw $VPNGW
route add -host 216.239.32.21 gw $VPNGW
route add -host 216.239.34.21 gw $VPNGW
route add -host 216.239.36.21 gw $VPNGW
route add -host 216.239.38.21 gw $VPNGW
route add -host 216.34.131.135 gw $VPNGW
route add -host 216.34.181.60 gw $VPNGW
route add -host 216.45.55.29 gw $VPNGW
route add -host 216.52.240.133 gw $VPNGW
route add -host 216.55.175.205 gw $VPNGW
route add -host 216.59.20.24 gw $VPNGW
route add -host 216.66.70.11 gw $VPNGW
route add -host 216.67.225.90 gw $VPNGW
route add -host 216.74.34.10 gw $VPNGW
route add -host 216.75.58.102 gw $VPNGW
route add -host 216.83.51.105 gw $VPNGW
route add -host 217.118.27.254 gw $VPNGW
route add -host 217.16.1.150 gw $VPNGW
route add -host 217.70.184.38 gw $VPNGW
route add -host 218.188.30.99 gw $VPNGW
route add -host 218.188.80.138 gw $VPNGW
route add -host 218.189.190.3 gw $VPNGW
route add -host 218.189.234.248 gw $VPNGW
route add -host 218.213.194.253 gw $VPNGW
route add -host 218.213.247.21 gw $VPNGW
route add -host 218.213.85.33 gw $VPNGW
route add -host 218.240.40.222 gw $VPNGW
route add -host 218.83.155.161 gw $VPNGW
route add -host 219.85.64.200 gw $VPNGW
route add -host 219.85.68.66 gw $VPNGW
route add -host 219.94.155.228 gw $VPNGW
route add -host 219.94.182.150 gw $VPNGW
route add -host 220.228.175.97 gw $VPNGW
route add -host 220.232.227.228 gw $VPNGW
route add -host 222.186.33.149 gw $VPNGW
route add -host 38.103.23.110 gw $VPNGW
route add -host 38.108.124.236 gw $VPNGW
route add -host 38.118.195.244 gw $VPNGW
route add -host 38.118.199.119 gw $VPNGW
route add -host 38.119.130.61 gw $VPNGW
route add -host 38.99.106.19 gw $VPNGW
route add -host 38.99.68.181 gw $VPNGW
route add -host 4.23.40.126 gw $VPNGW
route add -host 46.20.47.43 gw $VPNGW
route add -host 46.51.186.222 gw $VPNGW
route add -host 58.64.139.6 gw $VPNGW
route add -host 58.64.161.183 gw $VPNGW
route add -host 59.106.71.107 gw $VPNGW
route add -host 59.106.87.155 gw $VPNGW
route add -host 59.124.62.237 gw $VPNGW
route add -host 59.188.14.180 gw $VPNGW
route add -host 59.188.24.8 gw $VPNGW
route add -host 59.188.27.168 gw $VPNGW
route add -host 59.190.139.168 gw $VPNGW
route add -host 60.199.184.10 gw $VPNGW
route add -host 60.199.201.119 gw $VPNGW
route add -host 60.244.109.99 gw $VPNGW
route add -host 60.248.100.104 gw $VPNGW
route add -host 60.251.100.130 gw $VPNGW
route add -host 61.115.234.56 gw $VPNGW
route add -host 61.14.176.90 gw $VPNGW
route add -host 61.219.250.234 gw $VPNGW
route add -host 61.219.35.210 gw $VPNGW
route add -host 61.219.96.110 gw $VPNGW
route add -host 61.220.180.66 gw $VPNGW
route add -host 61.238.158.50 gw $VPNGW
route add -host 61.244.109.51 gw $VPNGW
route add -host 61.31.193.65 gw $VPNGW
route add -host 61.57.140.166 gw $VPNGW
route add -host 61.63.27.33 gw $VPNGW
route add -host 61.63.73.81 gw $VPNGW
route add -host 61.66.28.3 gw $VPNGW
route add -host 61.67.193.19 gw $VPNGW
route add -host 61.92.218.12 gw $VPNGW
route add -host 62.149.33.77 gw $VPNGW
route add -host 62.50.44.98 gw $VPNGW
route add -host 62.75.145.182 gw $VPNGW
route add -host 63.216.198.111 gw $VPNGW
route add -host 63.231.199.143 gw $VPNGW
route add -host 64.12.89.139 gw $VPNGW
route add -host 64.120.176.194 gw $VPNGW
route add -host 64.14.48.143 gw $VPNGW
route add -host 64.147.115.80 gw $VPNGW
route add -host 64.186.132.212 gw $VPNGW
route add -host 64.191.56.6 gw $VPNGW
route add -host 64.202.189.170 gw $VPNGW
route add -host 64.233.179.121 gw $VPNGW
route add -host 64.236.55.244 gw $VPNGW
route add -host 64.241.25.182 gw $VPNGW
route add -host 64.26.27.113 gw $VPNGW
route add -host 64.27.13.195 gw $VPNGW
route add -host 64.34.183.164 gw $VPNGW
route add -host 64.34.197.175 gw $VPNGW
route add -host 64.38.239.170 gw $VPNGW
route add -host 64.50.165.36 gw $VPNGW
route add -host 64.62.138.50 gw $VPNGW
route add -host 64.62.151.91 gw $VPNGW
route add -host 64.62.205.205 gw $VPNGW
route add -host 64.62.243.106 gw $VPNGW
route add -host 64.69.32.91 gw $VPNGW
route add -host 64.71.141.252 gw $VPNGW
route add -host 64.71.164.56 gw $VPNGW
route add -host 64.71.33.150 gw $VPNGW
route add -host 64.71.34.21 gw $VPNGW
route add -host 64.78.167.62 gw $VPNGW
route add -host 64.78.169.187 gw $VPNGW
route add -host 64.79.79.227 gw $VPNGW
route add -host 64.85.160.208 gw $VPNGW
route add -host 64.88.249.35 gw $VPNGW
route add -host 64.88.254.216 gw $VPNGW
route add -host 64.94.234.144 gw $VPNGW
route add -host 65.182.101.84 gw $VPNGW
route add -host 65.23.158.6 gw $VPNGW
route add -host 65.254.231.126 gw $VPNGW
route add -host 65.39.205.54 gw $VPNGW
route add -host 65.49.14.30 gw $VPNGW
route add -host 65.49.68.20 gw $VPNGW
route add -host 65.55.114.220 gw $VPNGW
route add -host 65.55.124.220 gw $VPNGW
route add -host 65.60.9.34 gw $VPNGW
route add -host 66.114.53.38 gw $VPNGW
route add -host 66.115.130.53 gw $VPNGW
route add -host 66.119.43.30 gw $VPNGW
route add -host 66.147.244.193 gw $VPNGW
route add -host 66.149.145.196 gw $VPNGW
route add -host 66.150.162.6 gw $VPNGW
route add -host 66.151.110.206 gw $VPNGW
route add -host 66.159.230.113 gw $VPNGW
route add -host 66.160.183.121 gw $VPNGW
route add -host 66.163.168.216 gw $VPNGW
route add -host 66.220.149.32 gw $VPNGW
route add -host 66.220.29.79 gw $VPNGW
route add -host 66.235.112.64 gw $VPNGW
route add -host 66.235.126.128 gw $VPNGW
route add -host 66.249.81.121 gw $VPNGW
route add -host 66.33.200.220 gw $VPNGW
route add -host 66.55.144.100 gw $VPNGW
route add -host 66.55.148.52 gw $VPNGW
route add -host 66.6.21.25 gw $VPNGW
route add -host 66.7.221.78 gw $VPNGW
route add -host 66.84.31.175 gw $VPNGW
route add -host 66.90.74.226 gw $VPNGW
route add -host 66.96.133.14 gw $VPNGW
route add -host 66.96.146.30 gw $VPNGW
route add -host 66.98.164.69 gw $VPNGW
route add -host 67.134.178.32 gw $VPNGW
route add -host 67.15.136.211 gw $VPNGW
route add -host 67.15.149.69 gw $VPNGW
route add -host 67.15.157.25 gw $VPNGW
route add -host 67.159.44.96 gw $VPNGW
route add -host 67.159.60.57 gw $VPNGW
route add -host 67.18.168.242 gw $VPNGW
route add -host 67.18.91.26 gw $VPNGW
route add -host 67.19.136.218 gw $VPNGW
route add -host 67.192.251.140 gw $VPNGW
route add -host 67.192.97.104 gw $VPNGW
route add -host 67.20.99.163 gw $VPNGW
route add -host 67.201.54.151 gw $VPNGW
route add -host 67.202.41.251 gw $VPNGW
route add -host 67.205.3.59 gw $VPNGW
route add -host 67.205.42.138 gw $VPNGW
route add -host 67.205.44.63 gw $VPNGW
route add -host 67.205.62.127 gw $VPNGW
route add -host 67.205.93.146 gw $VPNGW
route add -host 67.207.140.210 gw $VPNGW
route add -host 67.208.116.200 gw $VPNGW
route add -host 67.220.91.30 gw $VPNGW
route add -host 67.221.166.20 gw $VPNGW
route add -host 67.221.180.135 gw $VPNGW
route add -host 67.225.196.90 gw $VPNGW
route add -host 67.228.10.80 gw $VPNGW
route add -host 67.228.196.243 gw $VPNGW
route add -host 67.228.224.19 gw $VPNGW
route add -host 67.228.74.123 gw $VPNGW
route add -host 67.228.87.82 gw $VPNGW
route add -host 67.23.1.237 gw $VPNGW
route add -host 68.142.213.151 gw $VPNGW
route add -host 68.142.214.24 gw $VPNGW
route add -host 68.178.232.99 gw $VPNGW
route add -host 68.178.254.170 gw $VPNGW
route add -host 68.180.206.184 gw $VPNGW
route add -host 68.71.38.118 gw $VPNGW
route add -host 69.10.32.154 gw $VPNGW
route add -host 69.10.35.192 gw $VPNGW
route add -host 69.147.246.154 gw $VPNGW
route add -host 69.162.65.139 gw $VPNGW
route add -host 69.162.85.130 gw $VPNGW
route add -host 69.163.140.32 gw $VPNGW
route add -host 69.163.147.6 gw $VPNGW
route add -host 69.163.149.39 gw $VPNGW
route add -host 69.163.154.207 gw $VPNGW
route add -host 69.163.166.105 gw $VPNGW
route add -host 69.163.171.42 gw $VPNGW
route add -host 69.163.176.62 gw $VPNGW
route add -host 69.163.178.255 gw $VPNGW
route add -host 69.163.194.245 gw $VPNGW
route add -host 69.163.202.240 gw $VPNGW
route add -host 69.163.205.225 gw $VPNGW
route add -host 69.163.208.63 gw $VPNGW
route add -host 69.163.211.36 gw $VPNGW
route add -host 69.163.229.237 gw $VPNGW
route add -host 69.163.231.97 gw $VPNGW
route add -host 69.163.232.239 gw $VPNGW
route add -host 69.163.236.190 gw $VPNGW
route add -host 69.163.242.152 gw $VPNGW
route add -host 69.164.197.228 gw $VPNGW
route add -host 69.172.200.27 gw $VPNGW
route add -host 69.175.94.114 gw $VPNGW
route add -host 69.197.153.220 gw $VPNGW
route add -host 69.20.11.136 gw $VPNGW
route add -host 69.26.170.8 gw $VPNGW
route add -host 69.28.65.65 gw $VPNGW
route add -host 69.31.136.5 gw $VPNGW
route add -host 69.36.241.244 gw $VPNGW
route add -host 69.41.161.6 gw $VPNGW
route add -host 69.42.223.57 gw $VPNGW
route add -host 69.44.181.242 gw $VPNGW
route add -host 69.50.222.117 gw $VPNGW
route add -host 69.55.48.246 gw $VPNGW
route add -host 69.55.52.200 gw $VPNGW
route add -host 69.60.7.199 gw $VPNGW
route add -host 69.61.73.161 gw $VPNGW
route add -host 69.63.180.52 gw $VPNGW
route add -host 69.63.181.12 gw $VPNGW
route add -host 69.65.24.114 gw $VPNGW
route add -host 69.65.42.159 gw $VPNGW
route add -host 69.65.60.129 gw $VPNGW
route add -host 69.72.177.140 gw $VPNGW
route add -host 69.73.138.107 gw $VPNGW
route add -host 69.73.184.208 gw $VPNGW
route add -host 69.90.160.35 gw $VPNGW
route add -host 69.90.74.20 gw $VPNGW
route add -host 69.93.107.113 gw $VPNGW
route add -host 69.93.124.162 gw $VPNGW
route add -host 69.93.206.250 gw $VPNGW
route add -host 70.32.107.173 gw $VPNGW
route add -host 70.32.68.150 gw $VPNGW
route add -host 70.32.76.212 gw $VPNGW
route add -host 70.32.96.58 gw $VPNGW
route add -host 70.39.67.77 gw $VPNGW
route add -host 70.40.206.185 gw $VPNGW
route add -host 70.42.185.10 gw $VPNGW
route add -host 70.85.48.247 gw $VPNGW
route add -host 70.86.26.228 gw $VPNGW
route add -host 70.86.57.178 gw $VPNGW
route add -host 70.87.59.134 gw $VPNGW
route add -host 71.204.172.205 gw $VPNGW
route add -host 72.14.183.15 gw $VPNGW
route add -host 72.14.207.121 gw $VPNGW
route add -host 72.14.213.104 gw $VPNGW
route add -host 72.167.139.129 gw $VPNGW
route add -host 72.167.172.50 gw $VPNGW
route add -host 72.167.189.121 gw $VPNGW
route add -host 72.172.88.21 gw $VPNGW
route add -host 72.21.206.70 gw $VPNGW
route add -host 72.21.211.32 gw $VPNGW
route add -host 72.21.91.19 gw $VPNGW
route add -host 72.232.198.101 gw $VPNGW
route add -host 72.233.2.58 gw $VPNGW
route add -host 72.233.69.6 gw $VPNGW
route add -host 72.249.109.102 gw $VPNGW
route add -host 72.249.186.50 gw $VPNGW
route add -host 72.249.64.147 gw $VPNGW
route add -host 72.26.226.42 gw $VPNGW
route add -host 72.29.65.136 gw $VPNGW
route add -host 72.3.164.37 gw $VPNGW
route add -host 72.32.120.222 gw $VPNGW
route add -host 72.32.196.156 gw $VPNGW
route add -host 72.32.231.8 gw $VPNGW
route add -host 72.52.77.3 gw $VPNGW
route add -host 72.9.159.223 gw $VPNGW
route add -host 72.9.241.82 gw $VPNGW
route add -host 74.112.128.10 gw $VPNGW
route add -host 74.117.58.146 gw $VPNGW
route add -host 74.117.63.123 gw $VPNGW
route add -host 74.122.174.250 gw $VPNGW
route add -host 74.125.45.100 gw $VPNGW
route add -host 74.125.53.121 gw $VPNGW
route add -host 74.125.67.100 gw $VPNGW
route add -host 74.125.95.93 gw $VPNGW
route add -host 74.200.243.251 gw $VPNGW
route add -host 74.200.244.59 gw $VPNGW
route add -host 74.205.65.180 gw $VPNGW
route add -host 74.207.244.105 gw $VPNGW
route add -host 74.207.250.219 gw $VPNGW
route add -host 74.207.251.150 gw $VPNGW
route add -host 74.208.10.7 gw $VPNGW
route add -host 74.208.182.80 gw $VPNGW
route add -host 74.208.20.130 gw $VPNGW
route add -host 74.208.218.82 gw $VPNGW
route add -host 74.208.228.201 gw $VPNGW
route add -host 74.208.31.254 gw $VPNGW
route add -host 74.208.62.234 gw $VPNGW
route add -host 74.220.199.61 gw $VPNGW
route add -host 74.220.201.139 gw $VPNGW
route add -host 74.220.219.59 gw $VPNGW
route add -host 74.50.3.52 gw $VPNGW
route add -host 74.52.111.194 gw $VPNGW
route add -host 74.52.140.155 gw $VPNGW
route add -host 74.52.149.66 gw $VPNGW
route add -host 74.52.159.212 gw $VPNGW
route add -host 74.52.63.28 gw $VPNGW
route add -host 74.53.233.237 gw $VPNGW
route add -host 74.53.243.114 gw $VPNGW
route add -host 74.53.67.8 gw $VPNGW
route add -host 74.54.139.178 gw $VPNGW
route add -host 74.54.30.85 gw $VPNGW
route add -host 74.54.82.151 gw $VPNGW
route add -host 74.55.127.155 gw $VPNGW
route add -host 74.55.210.141 gw $VPNGW
route add -host 74.55.75.54 gw $VPNGW
route add -host 74.55.98.186 gw $VPNGW
route add -host 74.82.1.253 gw $VPNGW
route add -host 74.82.162.2 gw $VPNGW
route add -host 74.82.173.199 gw $VPNGW
route add -host 74.84.138.74 gw $VPNGW
route add -host 74.86.132.192 gw $VPNGW
route add -host 74.86.142.3 gw $VPNGW
route add -host 74.86.183.204 gw $VPNGW
route add -host 74.86.203.162 gw $VPNGW
route add -host 74.86.73.18 gw $VPNGW
route add -host 74.86.9.97 gw $VPNGW
route add -host 75.101.137.176 gw $VPNGW
route add -host 75.101.138.171 gw $VPNGW
route add -host 75.101.148.217 gw $VPNGW
route add -host 75.101.155.42 gw $VPNGW
route add -host 75.119.202.194 gw $VPNGW
route add -host 75.119.205.36 gw $VPNGW
route add -host 75.119.209.96 gw $VPNGW
route add -host 75.119.219.103 gw $VPNGW
route add -host 75.125.121.99 gw $VPNGW
route add -host 75.125.177.58 gw $VPNGW
route add -host 75.125.192.58 gw $VPNGW
route add -host 75.126.137.161 gw $VPNGW
route add -host 75.126.182.36 gw $VPNGW
route add -host 75.126.244.113 gw $VPNGW
route add -host 76.12.10.110 gw $VPNGW
route add -host 76.125.244.150 gw $VPNGW
route add -host 76.73.18.92 gw $VPNGW
route add -host 76.73.40.250 gw $VPNGW
route add -host 77.247.178.32 gw $VPNGW
route add -host 77.247.179.176 gw $VPNGW
route add -host 77.87.179.116 gw $VPNGW
route add -host 78.46.39.209 gw $VPNGW
route add -host 8.12.222.126 gw $VPNGW
route add -host 8.17.172.71 gw $VPNGW
route add -host 8.6.19.68 gw $VPNGW
route add -host 80.67.162.8 gw $VPNGW
route add -host 80.69.72.12 gw $VPNGW
route add -host 80.83.114.92 gw $VPNGW
route add -host 80.94.77.67 gw $VPNGW
route add -host 82.147.11.31 gw $VPNGW
route add -host 83.222.126.242 gw $VPNGW
route add -host 84.16.80.73 gw $VPNGW
route add -host 84.16.92.183 gw $VPNGW
route add -host 84.45.63.21 gw $VPNGW
route add -host 85.10.213.97 gw $VPNGW
route add -host 85.17.153.56 gw $VPNGW
route add -host 85.17.76.195 gw $VPNGW
route add -host 85.214.117.101 gw $VPNGW
route add -host 85.214.130.224 gw $VPNGW
route add -host 85.214.18.161 gw $VPNGW
route add -host 85.214.47.70 gw $VPNGW
route add -host 85.233.202.178 gw $VPNGW
route add -host 86.59.30.36 gw $VPNGW
route add -host 87.106.116.167 gw $VPNGW
route add -host 87.106.148.28 gw $VPNGW
route add -host 87.230.90.132 gw $VPNGW
route add -host 88.151.243.8 gw $VPNGW
route add -host 88.86.118.148 gw $VPNGW
route add -host 89.151.116.55 gw $VPNGW
route add -host 89.185.228.111 gw $VPNGW
route add -host 89.238.179.133 gw $VPNGW
route add -host 91.121.182.159 gw $VPNGW
route add -host 91.121.27.37 gw $VPNGW
route add -host 91.192.108.30 gw $VPNGW
route add -host 91.194.60.32 gw $VPNGW
route add -host 92.48.110.5 gw $VPNGW
route add -host 92.61.153.229 gw $VPNGW
route add -host 94.136.55.26 gw $VPNGW
route add -host 94.75.247.165 gw $VPNGW
route add -host 94.76.239.85 gw $VPNGW
route add -host 95.101.245.50 gw $VPNGW
route add -host 95.211.112.220 gw $VPNGW
route add -host 95.211.9.39 gw $VPNGW
route add -host 96.0.105.82 gw $VPNGW
route add -host 96.46.7.187 gw $VPNGW
route add -host 96.56.10.219 gw $VPNGW
route add -host 96.9.134.26 gw $VPNGW
route add -host 97.74.19.135 gw $VPNGW
route add -host 97.74.204.213 gw $VPNGW
route add -host 97.74.82.184 gw $VPNGW
route add -host 98.124.199.1 gw $VPNGW
route add -host 98.126.132.155 gw $VPNGW
route add -host 98.126.44.253 gw $VPNGW
route add -host 98.129.174.16 gw $VPNGW
route add -host 98.129.178.208 gw $VPNGW
route add -host 98.129.76.121 gw $VPNGW
route add -host 98.130.128.34 gw $VPNGW
route add -host 98.136.60.143 gw $VPNGW
route add -host 98.136.92.79 gw $VPNGW
route add -host 98.137.133.178 gw $VPNGW
route add -host 98.137.46.72 gw $VPNGW
route add -host 98.139.50.166 gw $VPNGW
route add -host 98.139.83.132 gw $VPNGW
route add -host 98.142.221.10 gw $VPNGW
route add -host 98.143.152.26 gw $VPNGW
route add -host 98.158.184.40 gw $VPNGW
route add -host 99.192.139.241 gw $VPNGW
route add -net 111.92.236.0/24 gw $VPNGW
route add -net 123.242.230.0/24 gw $VPNGW
route add -net 128.241.116.0/24 gw $VPNGW
route add -net 128.242.245.0/24 gw $VPNGW
route add -net 130.242.18.0/24 gw $VPNGW
route add -net 137.227.232.0/24 gw $VPNGW
route add -net 137.227.241.0/24 gw $VPNGW
route add -net 140.112.172.0/24 gw $VPNGW
route add -net 146.82.202.0/24 gw $VPNGW
route add -net 146.82.203.0/24 gw $VPNGW
route add -net 146.82.204.0/24 gw $VPNGW
route add -net 149.48.228.0/24 gw $VPNGW
route add -net 152.46.7.0/24 gw $VPNGW
route add -net 152.61.128.0/24 gw $VPNGW
route add -net 173.192.60.0/24 gw $VPNGW
route add -net 173.227.66.0/24 gw $VPNGW
route add -net 174.140.154.0/24 gw $VPNGW
route add -net 174.36.20.0/24 gw $VPNGW
route add -net 174.36.30.0/24 gw $VPNGW
route add -net 174.36.58.0/24 gw $VPNGW
route add -net 178.63.94.0/24 gw $VPNGW
route add -net 184.72.253.0/24 gw $VPNGW
route add -net 188.65.120.0/24 gw $VPNGW
route add -net 202.177.15.0/24 gw $VPNGW
route add -net 202.181.198.0/24 gw $VPNGW
route add -net 202.39.235.0/24 gw $VPNGW
route add -net 202.60.254.0/24 gw $VPNGW
route add -net 203.194.200.0/24 gw $VPNGW
route add -net 203.77.186.0/24 gw $VPNGW
route add -net 204.152.214.0/24 gw $VPNGW
route add -net 204.244.166.0/24 gw $VPNGW
route add -net 204.244.167.0/24 gw $VPNGW
route add -net 204.74.212.0/24 gw $VPNGW
route add -net 205.178.152.0/24 gw $VPNGW
route add -net 205.188.238.0/24 gw $VPNGW
route add -net 206.108.48.0/24 gw $VPNGW
route add -net 206.108.49.0/24 gw $VPNGW
route add -net 206.108.54.0/24 gw $VPNGW
route add -net 207.162.210.0/24 gw $VPNGW
route add -net 207.200.74.0/24 gw $VPNGW
route add -net 207.66.182.0/24 gw $VPNGW
route add -net 208.109.138.0/24 gw $VPNGW
route add -net 208.43.60.0/24 gw $VPNGW
route add -net 208.68.18.0/24 gw $VPNGW
route add -net 208.75.252.0/24 gw $VPNGW
route add -net 208.78.68.0/24 gw $VPNGW
route add -net 208.80.184.0/24 gw $VPNGW
route add -net 208.88.180.0/24 gw $VPNGW
route add -net 208.94.1.0/24 gw $VPNGW
route add -net 208.94.241.0/24 gw $VPNGW
route add -net 208.94.3.0/24 gw $VPNGW
route add -net 208.96.32.0/24 gw $VPNGW
route add -net 209.133.27.0/24 gw $VPNGW
route add -net 209.246.126.0/24 gw $VPNGW
route add -net 209.51.181.0/24 gw $VPNGW
route add -net 209.62.55.0/24 gw $VPNGW
route add -net 209.85.30.0/24 gw $VPNGW
route add -net 210.17.183.0/24 gw $VPNGW
route add -net 210.17.215.0/24 gw $VPNGW
route add -net 210.242.17.0/24 gw $VPNGW
route add -net 210.243.166.0/24 gw $VPNGW
route add -net 210.244.31.0/24 gw $VPNGW
route add -net 210.245.164.0/24 gw $VPNGW
route add -net 211.72.248.0/24 gw $VPNGW
route add -net 213.186.33.0/24 gw $VPNGW
route add -net 213.52.252.0/24 gw $VPNGW
route add -net 216.104.161.0/24 gw $VPNGW
route add -net 216.155.130.0/24 gw $VPNGW
route add -net 216.18.228.0/24 gw $VPNGW
route add -net 216.239.138.0/24 gw $VPNGW
route add -net 219.87.83.0/24 gw $VPNGW
route add -net 219.96.104.0/24 gw $VPNGW
route add -net 220.228.147.0/24 gw $VPNGW
route add -net 38.101.236.0/24 gw $VPNGW
route add -net 38.229.70.0/24 gw $VPNGW
route add -net 38.99.76.0/24 gw $VPNGW
route add -net 38.99.77.0/24 gw $VPNGW
route add -net 58.177.149.0/24 gw $VPNGW
route add -net 59.188.18.0/24 gw $VPNGW
route add -net 60.199.245.0/24 gw $VPNGW
route add -net 60.199.247.0/24 gw $VPNGW
route add -net 60.254.140.0/24 gw $VPNGW
route add -net 60.254.185.0/24 gw $VPNGW
route add -net 61.111.250.0/24 gw $VPNGW
route add -net 61.31.212.0/24 gw $VPNGW
route add -net 61.63.34.0/24 gw $VPNGW
route add -net 61.63.52.0/24 gw $VPNGW
route add -net 63.150.131.0/24 gw $VPNGW
route add -net 63.251.171.0/24 gw $VPNGW
route add -net 64.182.117.0/24 gw $VPNGW
route add -net 64.182.119.0/24 gw $VPNGW
route add -net 64.237.33.0/24 gw $VPNGW
route add -net 64.237.47.0/24 gw $VPNGW
route add -net 64.4.37.0/24 gw $VPNGW
route add -net 64.74.223.0/24 gw $VPNGW
route add -net 64.78.165.0/24 gw $VPNGW
route add -net 65.49.2.0/24 gw $VPNGW
route add -net 66.147.240.0/24 gw $VPNGW
route add -net 66.147.242.0/24 gw $VPNGW
route add -net 66.150.161.0/24 gw $VPNGW
route add -net 66.96.130.0/24 gw $VPNGW
route add -net 66.96.131.0/24 gw $VPNGW
route add -net 66.96.216.0/24 gw $VPNGW
route add -net 67.23.129.0/24 gw $VPNGW
route add -net 68.233.230.0/24 gw $VPNGW
route add -net 69.163.141.0/24 gw $VPNGW
route add -net 69.163.142.0/24 gw $VPNGW
route add -net 69.163.223.0/24 gw $VPNGW
route add -net 69.167.127.0/24 gw $VPNGW
route add -net 69.175.106.0/24 gw $VPNGW
route add -net 69.175.29.0/24 gw $VPNGW
route add -net 69.25.27.0/24 gw $VPNGW
route add -net 69.43.160.0/24 gw $VPNGW
route add -net 69.55.51.0/24 gw $VPNGW
route add -net 69.55.53.0/24 gw $VPNGW
route add -net 69.55.59.0/24 gw $VPNGW
route add -net 69.63.189.0/24 gw $VPNGW
route add -net 69.89.31.0/24 gw $VPNGW
route add -net 70.38.96.0/24 gw $VPNGW
route add -net 70.42.129.0/24 gw $VPNGW
route add -net 70.86.20.0/24 gw $VPNGW
route add -net 72.14.203.0/24 gw $VPNGW
route add -net 72.167.232.0/24 gw $VPNGW
route add -net 72.233.104.0/24 gw $VPNGW
route add -net 72.249.5.0/24 gw $VPNGW
route add -net 72.52.81.0/24 gw $VPNGW
route add -net 74.120.121.0/24 gw $VPNGW
route add -net 74.125.127.0/24 gw $VPNGW
route add -net 74.200.247.0/24 gw $VPNGW
route add -net 74.206.187.0/24 gw $VPNGW
route add -net 74.208.149.0/24 gw $VPNGW
route add -net 74.220.207.0/24 gw $VPNGW
route add -net 74.220.215.0/24 gw $VPNGW
route add -net 74.53.4.0/24 gw $VPNGW
route add -net 74.82.53.0/24 gw $VPNGW
route add -net 74.86.123.0/24 gw $VPNGW
route add -net 74.86.194.0/24 gw $VPNGW
route add -net 75.125.252.0/24 gw $VPNGW
route add -net 75.126.148.0/24 gw $VPNGW
route add -net 76.73.45.0/24 gw $VPNGW
route add -net 76.74.159.0/24 gw $VPNGW
route add -net 76.74.254.0/24 gw $VPNGW
route add -net 8.5.1.0/24 gw $VPNGW
route add -net 81.52.250.0/24 gw $VPNGW
route add -net 82.98.86.0/24 gw $VPNGW
route add -net 84.20.192.0/24 gw $VPNGW
route add -net 85.17.172.0/24 gw $VPNGW
route add -net 85.237.86.0/24 gw $VPNGW
route add -net 88.208.24.0/24 gw $VPNGW
route add -net 89.238.153.0/24 gw $VPNGW
route add -net 89.238.161.0/24 gw $VPNGW
route add -net 96.44.156.0/24 gw $VPNGW
route add -net 96.45.180.0/24 gw $VPNGW
route add -net 97.74.144.0/24 gw $VPNGW
route add -net 97.74.215.0/24 gw $VPNGW
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
				route del -net $r
				route add -net $r gw $OLDGW
			else
				route del $r
				route add $r gw $OLDGW
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
			route add -net $i gw $OLDGW
		else
			route add $i gw $OLDGW
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
		echo "$DEBUG GOOD"
		#echo "$INFO delete default gw $OLDGW" 
		#route del default gw $OLDGW
		#echo "$INFO add default gw $VPNGW again" 
		#route add default gw $VPNGW
		break
	else
		echo "$DEBUG default gw is not WAN GW"
		break
	fi
done

echo "$INFO static routes added"
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpnup.sh ended" >> $LOG
# release the lock
rm -f $LOCK
