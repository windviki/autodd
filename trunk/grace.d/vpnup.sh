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
				PPTPDEV=$(route -n | grep ^${VPNSRVSUB%.[0-9]*} | awk '{print $NF}' | head -n 1)
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


echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") adding the static routes, this may take a while." >> $LOG

##### begin batch route #####
# Google DNS and OpenDNS
route add -host 8.8.8.8 gw $VPNGW
route add -host 8.8.4.4 gw $VPNGW
route add -host 208.67.222.222 gw $VPNGW
# www.dropbox.com
#route add -host 174.36.30.70 gw $VPNGW
route add -net 174.36.30.0/24 gw $VPNGW
# dl-web.dropbox.com
route add -net 184.73..0.0/16 gw $VPNGW
route add -net 174.129.20/24 gw $VPNGW
route add -net 75.101.159.0/24 gw $VPNGW
route add -net 75.101.140.0/24 gw $VPNGW
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
# webcache.googleusercontent.com
route add -host 72.14.203.132 gw $VPNGW
route add -host 78.16.49.15 gw $VPNGW
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
# static.plurk.com
route add -host 74.120.123.19 gw $VPNGW
# statics.plurk.com
route add -net 216.137.53.0/24 gw $VPNGW
route add -net 216.137.55.0/24 gw $VPNGW
#tumblr.com
route add -host 174.120.238.130 gw $VPNGW
# tw.nextmedia.com
route add -host 210.242.234.140 gw $VPNGW
# {www|api}.twitter.com
route add -net 168.143.161.0/24 gw $VPNGW
route add -net 168.143.162.0/24 gw $VPNGW
route add -net 168.143.171.0/24 gw $VPNGW
route add -net 128.242.240.0/24 gw $VPNGW
route add -net 128.242.245.0/24 gw $VPNGW
route add -net 128.242.250.0/24 gw $VPNGW
# tw.news.yahoo.com
route add -net 203.84.204.0/24 gw $VPNGW
# pixnet.net
route add -net 103.23.108.0/24 gw $VPNGW
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
route add -net 198.87.176.0/24 gw $VPNGW
route add -net 96.17.8.0/24 gw $VPNGW
route add -net 204.2.171.0/24 gw $VPNGW
route add -net 208.46.163.0/24 gw $VPNGW
# *.vimeo.com
route add -net 66.235.126.0/24 gw $VPNGW
#route add -net 74.125.0.0/16 gw $VPNGW
route add -net 173.194.0.0/16 gw $VPNGW
route add -net 208.117.224.0/19 gw $VPNGW
route add -net 64.233.160.0/19 gw $VPNGW
# embed.wretch.cc
route add -net 203.188.204.0/24 gw $VPNGW
# pic.wretch.cc
route add -host 116.214.13.248 gw $VPNGW
route add -host 119.160.252.14 gw $VPNGW
# for all xuite
route add -net 210.242.17.0/24 gw $VPNGW
route add -net 210.242.18.0/24 gw $VPNGW
# www.books.com.tw
route add -net 61.31.206.0/24 gw $VPNGW
route add -net 58.86.40.0/24 gw $VPNGW
# all others
route add -host 101.101.96.51 gw $VPNGW
route add -host 101.78.134.153 gw $VPNGW
route add -host 106.10.165.51 gw $VPNGW
route add -host 106.187.100.93 gw $VPNGW
route add -host 106.187.37.184 gw $VPNGW
route add -host 107.20.136.244 gw $VPNGW
route add -host 107.20.154.114 gw $VPNGW
route add -host 107.20.178.167 gw $VPNGW
route add -host 107.21.243.42 gw $VPNGW
route add -host 107.21.26.195 gw $VPNGW
route add -host 107.21.7.89 gw $VPNGW
route add -host 107.21.95.3 gw $VPNGW
route add -host 107.23.81.170 gw $VPNGW
route add -host 108.160.154.214 gw $VPNGW
route add -host 108.162.197.199 gw $VPNGW
route add -host 108.162.205.107 gw $VPNGW
route add -host 108.162.206.107 gw $VPNGW
route add -host 108.175.161.226 gw $VPNGW
route add -host 108.61.37.254 gw $VPNGW
route add -host 108.61.4.52 gw $VPNGW
route add -host 109.104.79.84 gw $VPNGW
route add -host 109.233.153.1 gw $VPNGW
route add -host 109.239.54.15 gw $VPNGW
route add -host 110.232.178.193 gw $VPNGW
route add -host 110.34.141.187 gw $VPNGW
route add -host 110.45.229.152 gw $VPNGW
route add -host 111.92.236.18 gw $VPNGW
route add -host 113.253.129.176 gw $VPNGW
route add -host 113.28.60.58 gw $VPNGW
route add -host 114.141.199.247 gw $VPNGW
route add -host 114.142.150.200 gw $VPNGW
route add -host 114.32.90.158 gw $VPNGW
route add -host 115.160.156.212 gw $VPNGW
route add -host 116.90.87.217 gw $VPNGW
route add -host 117.56.25.3 gw $VPNGW
route add -host 117.56.6.1 gw $VPNGW
route add -host 118.142.78.123 gw $VPNGW
route add -host 118.143.65.100 gw $VPNGW
route add -host 118.173.204.2 gw $VPNGW
route add -host 118.215.12.79 gw $VPNGW
route add -host 119.160.242.96 gw $VPNGW
route add -host 119.246.129.9 gw $VPNGW
route add -host 119.246.135.11 gw $VPNGW
route add -host 12.69.32.89 gw $VPNGW
route add -host 121.127.250.228 gw $VPNGW
route add -host 121.50.176.24 gw $VPNGW
route add -host 122.147.183.31 gw $VPNGW
route add -host 122.152.128.122 gw $VPNGW
route add -host 122.209.125.55 gw $VPNGW
route add -host 122.248.242.240 gw $VPNGW
route add -host 123.204.17.109 gw $VPNGW
route add -host 123.242.224.113 gw $VPNGW
route add -host 124.150.130.98 gw $VPNGW
route add -host 124.150.132.8 gw $VPNGW
route add -host 124.232.137.15 gw $VPNGW
route add -host 124.244.11.95 gw $VPNGW
route add -host 124.9.13.21 gw $VPNGW
route add -host 125.114.250.163 gw $VPNGW
route add -host 125.29.60.4 gw $VPNGW
route add -host 125.56.201.114 gw $VPNGW
route add -host 125.6.190.4 gw $VPNGW
route add -host 128.100.171.12 gw $VPNGW
route add -host 130.242.18.28 gw $VPNGW
route add -host 131.111.179.80 gw $VPNGW
route add -host 131.228.39.189 gw $VPNGW
route add -host 133.242.1.242 gw $VPNGW
route add -host 14.0.36.78 gw $VPNGW
route add -host 14.0.37.245 gw $VPNGW
route add -host 14.198.48.55 gw $VPNGW
route add -host 14.199.47.27 gw $VPNGW
route add -host 140.109.29.253 gw $VPNGW
route add -host 140.123.188.66 gw $VPNGW
route add -host 141.8.225.7 gw $VPNGW
route add -host 142.4.50.154 gw $VPNGW
route add -host 142.54.164.245 gw $VPNGW
route add -host 149.174.144.2 gw $VPNGW
route add -host 149.174.149.2 gw $VPNGW
route add -host 149.47.226.135 gw $VPNGW
route add -host 154.35.160.5 gw $VPNGW
route add -host 154.35.164.8 gw $VPNGW
route add -host 158.255.212.89 gw $VPNGW
route add -host 160.68.205.231 gw $VPNGW
route add -host 165.83.19.13 gw $VPNGW
route add -host 169.207.67.17 gw $VPNGW
route add -host 170.140.52.142 gw $VPNGW
route add -host 170.140.53.44 gw $VPNGW
route add -host 173.192.111.15 gw $VPNGW
route add -host 173.192.64.147 gw $VPNGW
route add -host 173.193.138.224 gw $VPNGW
route add -host 173.194.77.121 gw $VPNGW
route add -host 173.201.141.91 gw $VPNGW
route add -host 173.203.217.152 gw $VPNGW
route add -host 173.203.221.57 gw $VPNGW
route add -host 173.203.238.64 gw $VPNGW
route add -host 173.224.213.17 gw $VPNGW
route add -host 173.230.153.165 gw $VPNGW
route add -host 173.230.156.6 gw $VPNGW
route add -host 173.231.52.116 gw $VPNGW
route add -host 173.231.9.232 gw $VPNGW
route add -host 173.234.235.36 gw $VPNGW
route add -host 173.236.162.231 gw $VPNGW
route add -host 173.236.178.66 gw $VPNGW
route add -host 173.236.198.233 gw $VPNGW
route add -host 173.236.215.26 gw $VPNGW
route add -host 173.236.218.197 gw $VPNGW
route add -host 173.236.241.90 gw $VPNGW
route add -host 173.236.84.94 gw $VPNGW
route add -host 173.247.252.117 gw $VPNGW
route add -host 173.249.151.129 gw $VPNGW
route add -host 173.254.212.124 gw $VPNGW
route add -host 173.254.238.194 gw $VPNGW
route add -host 173.255.192.14 gw $VPNGW
route add -host 173.255.211.163 gw $VPNGW
route add -host 173.255.217.40 gw $VPNGW
route add -host 173.255.219.152 gw $VPNGW
route add -host 173.255.226.201 gw $VPNGW
route add -host 173.255.246.187 gw $VPNGW
route add -host 173.255.249.229 gw $VPNGW
route add -host 174.120.146.114 gw $VPNGW
route add -host 174.120.189.254 gw $VPNGW
route add -host 174.122.148.99 gw $VPNGW
route add -host 174.122.244.179 gw $VPNGW
route add -host 174.122.246.123 gw $VPNGW
route add -host 174.122.45.123 gw $VPNGW
route add -host 174.127.106.50 gw $VPNGW
route add -host 174.127.109.132 gw $VPNGW
route add -host 174.129.1.157 gw $VPNGW
route add -host 174.129.182.241 gw $VPNGW
route add -host 174.129.192.155 gw $VPNGW
route add -host 174.129.197.181 gw $VPNGW
route add -host 174.129.20.208 gw $VPNGW
route add -host 174.129.202.202 gw $VPNGW
route add -host 174.129.212.2 gw $VPNGW
route add -host 174.129.227.239 gw $VPNGW
route add -host 174.129.228.246 gw $VPNGW
route add -host 174.129.242.247 gw $VPNGW
route add -host 174.129.247.225 gw $VPNGW
route add -host 174.129.248.69 gw $VPNGW
route add -host 174.129.249.253 gw $VPNGW
route add -host 174.129.32.46 gw $VPNGW
route add -host 174.132.147.60 gw $VPNGW
route add -host 174.132.151.226 gw $VPNGW
route add -host 174.132.157.59 gw $VPNGW
route add -host 174.132.186.206 gw $VPNGW
route add -host 174.132.96.140 gw $VPNGW
route add -host 174.133.217.98 gw $VPNGW
route add -host 174.136.35.43 gw $VPNGW
route add -host 174.139.15.210 gw $VPNGW
route add -host 174.143.151.131 gw $VPNGW
route add -host 174.143.243.139 gw $VPNGW
route add -host 174.34.155.20 gw $VPNGW
route add -host 174.36.107.130 gw $VPNGW
route add -host 174.36.153.130 gw $VPNGW
route add -host 174.36.183.108 gw $VPNGW
route add -host 174.36.186.208 gw $VPNGW
route add -host 174.36.228.137 gw $VPNGW
route add -host 174.36.241.116 gw $VPNGW
route add -host 174.36.28.11 gw $VPNGW
route add -host 174.36.58.169 gw $VPNGW
route add -host 174.37.129.192 gw $VPNGW
route add -host 174.37.135.211 gw $VPNGW
route add -host 174.37.15.12 gw $VPNGW
route add -host 174.37.172.162 gw $VPNGW
route add -host 175.45.56.246 gw $VPNGW
route add -host 176.28.41.173 gw $VPNGW
route add -host 176.34.42.54 gw $VPNGW
route add -host 176.9.124.44 gw $VPNGW
route add -host 176.9.137.75 gw $VPNGW
route add -host 176.9.138.220 gw $VPNGW
route add -host 178.21.134.169 gw $VPNGW
route add -host 178.32.28.100 gw $VPNGW
route add -host 178.63.94.57 gw $VPNGW
route add -host 180.188.194.12 gw $VPNGW
route add -host 180.233.142.129 gw $VPNGW
route add -host 182.163.74.136 gw $VPNGW
route add -host 182.50.135.17 gw $VPNGW
route add -host 183.179.189.129 gw $VPNGW
route add -host 183.179.98.23 gw $VPNGW
route add -host 184.105.134.179 gw $VPNGW
route add -host 184.105.178.84 gw $VPNGW
route add -host 184.105.207.34 gw $VPNGW
route add -host 184.106.180.60 gw $VPNGW
route add -host 184.106.20.99 gw $VPNGW
route add -host 184.154.128.246 gw $VPNGW
route add -host 184.154.48.218 gw $VPNGW
route add -host 184.168.116.149 gw $VPNGW
route add -host 184.168.120.2 gw $VPNGW
route add -host 184.168.152.27 gw $VPNGW
route add -host 184.168.192.118 gw $VPNGW
route add -host 184.168.229.1 gw $VPNGW
route add -host 184.168.70.179 gw $VPNGW
route add -host 184.169.172.216 gw $VPNGW
route add -host 184.172.173.99 gw $VPNGW
route add -host 184.173.131.9 gw $VPNGW
route add -host 184.173.166.40 gw $VPNGW
route add -host 184.173.175.224 gw $VPNGW
route add -host 184.22.83.151 gw $VPNGW
route add -host 184.26.245.50 gw $VPNGW
route add -host 184.72.125.210 gw $VPNGW
route add -host 184.72.221.111 gw $VPNGW
route add -host 184.72.246.159 gw $VPNGW
route add -host 184.73.155.93 gw $VPNGW
route add -host 184.73.165.65 gw $VPNGW
route add -host 184.73.180.6 gw $VPNGW
route add -host 184.73.216.15 gw $VPNGW
route add -host 184.82.170.148 gw $VPNGW
route add -host 184.82.227.135 gw $VPNGW
route add -host 184.82.34.68 gw $VPNGW
route add -host 188.165.218.147 gw $VPNGW
route add -host 188.190.97.231 gw $VPNGW
route add -host 188.241.112.92 gw $VPNGW
route add -host 188.40.179.86 gw $VPNGW
route add -host 188.65.112.130 gw $VPNGW
route add -host 192.121.86.163 gw $VPNGW
route add -host 192.168.1.1 gw $VPNGW
route add -host 194.55.26.46 gw $VPNGW
route add -host 194.55.30.46 gw $VPNGW
route add -host 194.71.107.50 gw $VPNGW
route add -host 194.9.94.79 gw $VPNGW
route add -host 194.90.190.55 gw $VPNGW
route add -host 195.14.0.137 gw $VPNGW
route add -host 195.234.175.160 gw $VPNGW
route add -host 195.242.152.250 gw $VPNGW
route add -host 195.93.80.46 gw $VPNGW
route add -host 195.93.85.44 gw $VPNGW
route add -host 198.244.51.13 gw $VPNGW
route add -host 198.65.239.132 gw $VPNGW
route add -host 198.74.57.190 gw $VPNGW
route add -host 199.101.103.46 gw $VPNGW
route add -host 199.101.134.235 gw $VPNGW
route add -host 199.119.201.156 gw $VPNGW
route add -host 199.175.49.70 gw $VPNGW
route add -host 199.187.121.51 gw $VPNGW
route add -host 199.188.200.4 gw $VPNGW
route add -host 199.19.110.124 gw $VPNGW
route add -host 199.204.248.104 gw $VPNGW
route add -host 199.231.189.110 gw $VPNGW
route add -host 199.27.75.131 gw $VPNGW
route add -host 199.58.84.76 gw $VPNGW
route add -host 199.58.86.133 gw $VPNGW
route add -host 199.59.161.102 gw $VPNGW
route add -host 199.59.163.213 gw $VPNGW
route add -host 199.59.241.181 gw $VPNGW
route add -host 199.80.55.135 gw $VPNGW
route add -host 199.83.93.62 gw $VPNGW
route add -host 199.9.250.77 gw $VPNGW
route add -host 199.93.55.126 gw $VPNGW
route add -host 202.108.5.131 gw $VPNGW
route add -host 202.123.75.56 gw $VPNGW
route add -host 202.123.82.23 gw $VPNGW
route add -host 202.125.90.20 gw $VPNGW
route add -host 202.153.205.170 gw $VPNGW
route add -host 202.167.238.189 gw $VPNGW
route add -host 202.172.25.33 gw $VPNGW
route add -host 202.172.28.100 gw $VPNGW
route add -host 202.176.217.17 gw $VPNGW
route add -host 202.181.167.115 gw $VPNGW
route add -host 202.181.195.252 gw $VPNGW
route add -host 202.181.207.207 gw $VPNGW
route add -host 202.181.238.98 gw $VPNGW
route add -host 202.190.173.52 gw $VPNGW
route add -host 202.190.186.43 gw $VPNGW
route add -host 202.214.8.82 gw $VPNGW
route add -host 202.218.113.54 gw $VPNGW
route add -host 202.218.250.72 gw $VPNGW
route add -host 202.27.28.10 gw $VPNGW
route add -host 202.39.176.53 gw $VPNGW
route add -host 202.55.234.106 gw $VPNGW
route add -host 202.66.136.20 gw $VPNGW
route add -host 202.67.195.96 gw $VPNGW
route add -host 202.67.226.114 gw $VPNGW
route add -host 202.67.247.125 gw $VPNGW
route add -host 202.71.100.186 gw $VPNGW
route add -host 202.81.252.243 gw $VPNGW
route add -host 202.85.162.104 gw $VPNGW
route add -host 203.105.2.20 gw $VPNGW
route add -host 203.131.229.38 gw $VPNGW
route add -host 203.133.28.11 gw $VPNGW
route add -host 203.137.0.166 gw $VPNGW
route add -host 203.141.139.184 gw $VPNGW
route add -host 203.171.229.98 gw $VPNGW
route add -host 203.188.197.200 gw $VPNGW
route add -host 203.209.156.119 gw $VPNGW
route add -host 203.27.227.220 gw $VPNGW
route add -host 203.69.37.172 gw $VPNGW
route add -host 203.80.0.172 gw $VPNGW
route add -host 203.90.230.221 gw $VPNGW
route add -host 203.98.7.65 gw $VPNGW
route add -host 204.1.152.83 gw $VPNGW
route add -host 204.107.28.181 gw $VPNGW
route add -host 204.110.13.184 gw $VPNGW
route add -host 204.13.160.107 gw $VPNGW
route add -host 204.145.120.172 gw $VPNGW
route add -host 204.152.254.121 gw $VPNGW
route add -host 204.152.255.35 gw $VPNGW
route add -host 204.16.194.196 gw $VPNGW
route add -host 204.160.103.126 gw $VPNGW
route add -host 204.179.240.180 gw $VPNGW
route add -host 204.236.239.5 gw $VPNGW
route add -host 204.246.163.134 gw $VPNGW
route add -host 204.74.216.174 gw $VPNGW
route add -host 204.9.177.195 gw $VPNGW
route add -host 205.178.152.24 gw $VPNGW
route add -host 205.188.100.58 gw $VPNGW
route add -host 205.188.101.58 gw $VPNGW
route add -host 205.188.28.118 gw $VPNGW
route add -host 205.188.87.118 gw $VPNGW
route add -host 205.196.221.62 gw $VPNGW
route add -host 205.209.175.94 gw $VPNGW
route add -host 206.108.49.19 gw $VPNGW
route add -host 206.108.50.102 gw $VPNGW
route add -host 206.108.54.30 gw $VPNGW
route add -host 206.125.164.82 gw $VPNGW
route add -host 206.33.55.126 gw $VPNGW
route add -host 206.46.232.39 gw $VPNGW
route add -host 207.171.166.22 gw $VPNGW
route add -host 207.200.74.38 gw $VPNGW
route add -host 207.241.224.2 gw $VPNGW
route add -host 208.101.9.144 gw $VPNGW
route add -host 208.109.181.211 gw $VPNGW
route add -host 208.109.53.2 gw $VPNGW
route add -host 208.109.78.133 gw $VPNGW
route add -host 208.113.201.160 gw $VPNGW
route add -host 208.131.25.34 gw $VPNGW
route add -host 208.167.225.104 gw $VPNGW
route add -host 208.43.237.140 gw $VPNGW
route add -host 208.51.62.2 gw $VPNGW
route add -host 208.66.65.239 gw $VPNGW
route add -host 208.68.17.67 gw $VPNGW
route add -host 208.69.4.141 gw $VPNGW
route add -host 208.71.106.124 gw $VPNGW
route add -host 208.73.211.11 gw $VPNGW
route add -host 208.75.184.192 gw $VPNGW
route add -host 208.80.56.11 gw $VPNGW
route add -host 208.82.16.68 gw $VPNGW
route add -host 208.86.184.80 gw $VPNGW
route add -host 208.87.35.104 gw $VPNGW
route add -host 208.88.182.181 gw $VPNGW
route add -host 208.91.197.104 gw $VPNGW
route add -host 208.92.218.173 gw $VPNGW
route add -host 208.94.1.8 gw $VPNGW
route add -host 208.94.2.7 gw $VPNGW
route add -host 208.94.244.98 gw $VPNGW
route add -host 208.95.173.130 gw $VPNGW
route add -host 208.99.72.37 gw $VPNGW
route add -host 209.160.20.56 gw $VPNGW
route add -host 209.17.130.1 gw $VPNGW
route add -host 209.17.69.216 gw $VPNGW
route add -host 209.197.73.62 gw $VPNGW
route add -host 209.20.66.131 gw $VPNGW
route add -host 209.20.83.245 gw $VPNGW
route add -host 209.20.95.202 gw $VPNGW
route add -host 209.200.244.207 gw $VPNGW
route add -host 209.205.75.81 gw $VPNGW
route add -host 209.222.1.145 gw $VPNGW
route add -host 209.222.2.149 gw $VPNGW
route add -host 209.246.126.162 gw $VPNGW
route add -host 209.249.47.10 gw $VPNGW
route add -host 209.25.137.150 gw $VPNGW
route add -host 209.51.140.2 gw $VPNGW
route add -host 209.62.69.106 gw $VPNGW
route add -host 209.85.171.121 gw $VPNGW
route add -host 210.0.141.99 gw $VPNGW
route add -host 210.155.101.196 gw $VPNGW
route add -host 210.155.3.54 gw $VPNGW
route add -host 210.17.189.182 gw $VPNGW
route add -host 210.17.215.63 gw $VPNGW
route add -host 210.17.252.133 gw $VPNGW
route add -host 210.172.144.245 gw $VPNGW
route add -host 210.200.133.135 gw $VPNGW
route add -host 210.202.41.248 gw $VPNGW
route add -host 210.242.195.60 gw $VPNGW
route add -host 210.59.228.219 gw $VPNGW
route add -host 210.6.47.139 gw $VPNGW
route add -host 211.13.210.84 gw $VPNGW
route add -host 211.233.75.83 gw $VPNGW
route add -host 211.72.203.61 gw $VPNGW
route add -host 211.72.204.197 gw $VPNGW
route add -host 211.75.131.205 gw $VPNGW
route add -host 211.95.79.60 gw $VPNGW
route add -host 212.118.245.201 gw $VPNGW
route add -host 212.27.48.10 gw $VPNGW
route add -host 212.44.108.73 gw $VPNGW
route add -host 212.58.241.131 gw $VPNGW
route add -host 212.58.244.71 gw $VPNGW
route add -host 212.64.146.224 gw $VPNGW
route add -host 213.139.108.166 gw $VPNGW
route add -host 213.171.192.129 gw $VPNGW
route add -host 213.186.33.2 gw $VPNGW
route add -host 213.73.89.122 gw $VPNGW
route add -host 216.108.229.6 gw $VPNGW
route add -host 216.12.198.251 gw $VPNGW
route add -host 216.12.210.66 gw $VPNGW
route add -host 216.131.83.58 gw $VPNGW
route add -host 216.131.84.124 gw $VPNGW
route add -host 216.139.208.243 gw $VPNGW
route add -host 216.139.245.46 gw $VPNGW
route add -host 216.139.249.222 gw $VPNGW
route add -host 216.15.252.72 gw $VPNGW
route add -host 216.150.214.58 gw $VPNGW
route add -host 216.155.144.20 gw $VPNGW
route add -host 216.172.184.211 gw $VPNGW
route add -host 216.172.189.146 gw $VPNGW
route add -host 216.178.46.224 gw $VPNGW
route add -host 216.18.170.229 gw $VPNGW
route add -host 216.18.205.213 gw $VPNGW
route add -host 216.18.22.50 gw $VPNGW
route add -host 216.218.229.131 gw $VPNGW
route add -host 216.224.185.189 gw $VPNGW
route add -host 216.230.250.151 gw $VPNGW
route add -host 216.239.138.60 gw $VPNGW
route add -host 216.239.32.21 gw $VPNGW
route add -host 216.239.34.21 gw $VPNGW
route add -host 216.239.36.21 gw $VPNGW
route add -host 216.239.38.21 gw $VPNGW
route add -host 216.240.128.65 gw $VPNGW
route add -host 216.240.187.140 gw $VPNGW
route add -host 216.35.74.104 gw $VPNGW
route add -host 216.40.204.139 gw $VPNGW
route add -host 216.55.175.205 gw $VPNGW
route add -host 216.67.225.90 gw $VPNGW
route add -host 216.69.227.70 gw $VPNGW
route add -host 216.74.34.10 gw $VPNGW
route add -host 216.75.233.248 gw $VPNGW
route add -host 216.75.58.102 gw $VPNGW
route add -host 216.92.168.131 gw $VPNGW
route add -host 217.160.115.96 gw $VPNGW
route add -host 217.160.95.206 gw $VPNGW
route add -host 217.70.184.38 gw $VPNGW
route add -host 218.188.30.99 gw $VPNGW
route add -host 218.211.37.253 gw $VPNGW
route add -host 218.213.244.64 gw $VPNGW
route add -host 218.213.85.33 gw $VPNGW
route add -host 218.240.40.222 gw $VPNGW
route add -host 219.85.64.200 gw $VPNGW
route add -host 219.85.68.33 gw $VPNGW
route add -host 219.87.83.8 gw $VPNGW
route add -host 219.94.182.150 gw $VPNGW
route add -host 219.94.192.102 gw $VPNGW
route add -host 220.181.136.233 gw $VPNGW
route add -host 220.228.175.97 gw $VPNGW
route add -host 220.232.227.228 gw $VPNGW
route add -host 23.21.241.131 gw $VPNGW
route add -host 23.21.41.90 gw $VPNGW
route add -host 23.23.101.40 gw $VPNGW
route add -host 23.23.111.137 gw $VPNGW
route add -host 23.23.161.76 gw $VPNGW
route add -host 23.23.192.105 gw $VPNGW
route add -host 23.23.89.103 gw $VPNGW
route add -host 23.23.90.136 gw $VPNGW
route add -host 23.29.120.74 gw $VPNGW
route add -host 23.41.67.153 gw $VPNGW
route add -host 23.42.65.162 gw $VPNGW
route add -host 24.173.168.101 gw $VPNGW
route add -host 31.192.116.24 gw $VPNGW
route add -host 31.192.117.132 gw $VPNGW
route add -host 31.7.59.14 gw $VPNGW
route add -host 38.103.23.89 gw $VPNGW
route add -host 38.118.195.244 gw $VPNGW
route add -host 38.119.130.61 gw $VPNGW
route add -host 38.127.224.164 gw $VPNGW
route add -host 38.99.106.19 gw $VPNGW
route add -host 42.121.98.156 gw $VPNGW
route add -host 46.105.190.218 gw $VPNGW
route add -host 46.163.85.198 gw $VPNGW
route add -host 46.165.210.145 gw $VPNGW
route add -host 46.4.149.25 gw $VPNGW
route add -host 46.4.95.26 gw $VPNGW
route add -host 46.51.243.56 gw $VPNGW
route add -host 50.112.139.252 gw $VPNGW
route add -host 50.112.146.218 gw $VPNGW
route add -host 50.116.85.107 gw $VPNGW
route add -host 50.16.102.253 gw $VPNGW
route add -host 50.16.185.16 gw $VPNGW
route add -host 50.16.215.104 gw $VPNGW
route add -host 50.17.203.33 gw $VPNGW
route add -host 50.18.171.55 gw $VPNGW
route add -host 50.18.190.126 gw $VPNGW
route add -host 50.19.122.222 gw $VPNGW
route add -host 50.19.93.35 gw $VPNGW
route add -host 50.22.112.32 gw $VPNGW
route add -host 50.22.218.180 gw $VPNGW
route add -host 50.22.235.76 gw $VPNGW
route add -host 50.23.120.99 gw $VPNGW
route add -host 50.23.146.179 gw $VPNGW
route add -host 50.23.85.172 gw $VPNGW
route add -host 50.28.69.147 gw $VPNGW
route add -host 50.28.86.184 gw $VPNGW
route add -host 50.31.83.77 gw $VPNGW
route add -host 50.56.152.232 gw $VPNGW
route add -host 50.57.202.71 gw $VPNGW
route add -host 50.57.205.237 gw $VPNGW
route add -host 50.63.121.1 gw $VPNGW
route add -host 50.63.220.1 gw $VPNGW
route add -host 50.63.67.229 gw $VPNGW
route add -host 50.63.91.1 gw $VPNGW
route add -host 50.93.194.9 gw $VPNGW
route add -host 50.97.47.83 gw $VPNGW
route add -host 54.248.127.64 gw $VPNGW
route add -host 54.248.33.195 gw $VPNGW
route add -host 54.248.90.179 gw $VPNGW
route add -host 58.64.139.25 gw $VPNGW
route add -host 58.64.157.144 gw $VPNGW
route add -host 58.64.161.183 gw $VPNGW
route add -host 58.64.176.204 gw $VPNGW
route add -host 58.64.189.137 gw $VPNGW
route add -host 58.68.168.147 gw $VPNGW
route add -host 58.68.255.34 gw $VPNGW
route add -host 59.105.179.173 gw $VPNGW
route add -host 59.106.167.73 gw $VPNGW
route add -host 59.106.87.155 gw $VPNGW
route add -host 59.120.18.7 gw $VPNGW
route add -host 59.124.62.237 gw $VPNGW
route add -host 59.149.87.113 gw $VPNGW
route add -host 59.151.129.50 gw $VPNGW
route add -host 59.188.14.180 gw $VPNGW
route add -host 59.188.16.248 gw $VPNGW
route add -host 59.188.24.8 gw $VPNGW
route add -host 59.190.139.168 gw $VPNGW
route add -host 60.199.178.101 gw $VPNGW
route add -host 60.199.184.10 gw $VPNGW
route add -host 60.199.201.119 gw $VPNGW
route add -host 60.199.249.12 gw $VPNGW
route add -host 60.244.109.99 gw $VPNGW
route add -host 60.248.100.104 gw $VPNGW
route add -host 60.251.100.130 gw $VPNGW
route add -host 60.254.133.135 gw $VPNGW
route add -host 60.254.169.249 gw $VPNGW
route add -host 61.111.250.219 gw $VPNGW
route add -host 61.115.234.56 gw $VPNGW
route add -host 61.14.176.90 gw $VPNGW
route add -host 61.147.124.216 gw $VPNGW
route add -host 61.152.104.212 gw $VPNGW
route add -host 61.219.35.230 gw $VPNGW
route add -host 61.219.96.84 gw $VPNGW
route add -host 61.220.180.66 gw $VPNGW
route add -host 61.238.158.50 gw $VPNGW
route add -host 61.244.110.200 gw $VPNGW
route add -host 61.31.193.65 gw $VPNGW
route add -host 61.63.25.209 gw $VPNGW
route add -host 61.63.27.33 gw $VPNGW
route add -host 61.63.34.194 gw $VPNGW
route add -host 61.63.73.81 gw $VPNGW
route add -host 61.92.215.90 gw $VPNGW
route add -host 62.116.181.25 gw $VPNGW
route add -host 62.212.83.1 gw $VPNGW
route add -host 62.50.44.98 gw $VPNGW
route add -host 63.135.90.224 gw $VPNGW
route add -host 63.247.137.26 gw $VPNGW
route add -host 64.12.79.57 gw $VPNGW
route add -host 64.12.89.186 gw $VPNGW
route add -host 64.120.176.194 gw $VPNGW
route add -host 64.14.48.143 gw $VPNGW
route add -host 64.147.115.80 gw $VPNGW
route add -host 64.18.206.121 gw $VPNGW
route add -host 64.202.189.170 gw $VPNGW
route add -host 64.210.140.16 gw $VPNGW
route add -host 64.237.53.214 gw $VPNGW
route add -host 64.26.27.113 gw $VPNGW
route add -host 64.31.24.3 gw $VPNGW
route add -host 64.34.174.11 gw $VPNGW
route add -host 64.4.37.223 gw $VPNGW
route add -host 64.62.138.50 gw $VPNGW
route add -host 64.71.34.21 gw $VPNGW
route add -host 64.78.163.162 gw $VPNGW
route add -host 64.85.160.208 gw $VPNGW
route add -host 64.88.249.35 gw $VPNGW
route add -host 64.88.254.216 gw $VPNGW
route add -host 64.90.58.191 gw $VPNGW
route add -host 65.182.101.84 gw $VPNGW
route add -host 65.19.157.227 gw $VPNGW
route add -host 65.254.231.126 gw $VPNGW
route add -host 65.254.248.219 gw $VPNGW
route add -host 65.39.205.54 gw $VPNGW
route add -host 65.49.77.192 gw $VPNGW
route add -host 66.11.225.38 gw $VPNGW
route add -host 66.115.130.53 gw $VPNGW
route add -host 66.119.43.30 gw $VPNGW
route add -host 66.147.240.159 gw $VPNGW
route add -host 66.151.111.150 gw $VPNGW
route add -host 66.159.230.113 gw $VPNGW
route add -host 66.160.183.121 gw $VPNGW
route add -host 66.175.217.77 gw $VPNGW
route add -host 66.175.58.9 gw $VPNGW
route add -host 66.180.175.246 gw $VPNGW
route add -host 66.212.18.245 gw $VPNGW
route add -host 66.212.30.253 gw $VPNGW
route add -host 66.215.3.167 gw $VPNGW
route add -host 66.220.149.88 gw $VPNGW
route add -host 66.220.152.16 gw $VPNGW
route add -host 66.220.158.70 gw $VPNGW
route add -host 66.226.82.194 gw $VPNGW
route add -host 66.230.193.63 gw $VPNGW
route add -host 66.254.109.120 gw $VPNGW
route add -host 66.33.200.220 gw $VPNGW
route add -host 66.6.21.25 gw $VPNGW
route add -host 66.7.221.78 gw $VPNGW
route add -host 66.90.74.226 gw $VPNGW
route add -host 66.96.133.14 gw $VPNGW
route add -host 66.96.147.105 gw $VPNGW
route add -host 66.96.162.133 gw $VPNGW
route add -host 67.18.19.178 gw $VPNGW
route add -host 67.18.91.26 gw $VPNGW
route add -host 67.192.97.104 gw $VPNGW
route add -host 67.195.61.65 gw $VPNGW
route add -host 67.201.54.151 gw $VPNGW
route add -host 67.202.41.251 gw $VPNGW
route add -host 67.205.29.250 gw $VPNGW
route add -host 67.205.3.59 gw $VPNGW
route add -host 67.205.42.205 gw $VPNGW
route add -host 67.205.56.172 gw $VPNGW
route add -host 67.205.93.146 gw $VPNGW
route add -host 67.207.140.210 gw $VPNGW
route add -host 67.213.218.16 gw $VPNGW
route add -host 67.215.236.234 gw $VPNGW
route add -host 67.220.50.32 gw $VPNGW
route add -host 67.221.180.135 gw $VPNGW
route add -host 67.227.181.208 gw $VPNGW
route add -host 67.228.102.72 gw $VPNGW
route add -host 67.228.120.147 gw $VPNGW
route add -host 67.228.185.98 gw $VPNGW
route add -host 67.228.223.11 gw $VPNGW
route add -host 67.228.224.19 gw $VPNGW
route add -host 67.228.226.225 gw $VPNGW
route add -host 67.228.247.187 gw $VPNGW
route add -host 67.228.81.182 gw $VPNGW
route add -host 67.228.87.82 gw $VPNGW
route add -host 67.23.1.237 gw $VPNGW
route add -host 67.23.36.223 gw $VPNGW
route add -host 68.171.142.147 gw $VPNGW
route add -host 68.178.254.189 gw $VPNGW
route add -host 68.180.206.184 gw $VPNGW
route add -host 68.233.172.37 gw $VPNGW
route add -host 68.67.61.247 gw $VPNGW
route add -host 68.71.38.118 gw $VPNGW
route add -host 68.71.52.214 gw $VPNGW
route add -host 69.10.32.156 gw $VPNGW
route add -host 69.10.35.192 gw $VPNGW
route add -host 69.147.246.154 gw $VPNGW
route add -host 69.161.144.104 gw $VPNGW
route add -host 69.162.78.10 gw $VPNGW
route add -host 69.163.140.23 gw $VPNGW
route add -host 69.163.154.207 gw $VPNGW
route add -host 69.163.171.42 gw $VPNGW
route add -host 69.163.176.62 gw $VPNGW
route add -host 69.163.178.255 gw $VPNGW
route add -host 69.163.185.66 gw $VPNGW
route add -host 69.163.192.7 gw $VPNGW
route add -host 69.163.204.186 gw $VPNGW
route add -host 69.163.205.225 gw $VPNGW
route add -host 69.163.208.63 gw $VPNGW
route add -host 69.163.221.87 gw $VPNGW
route add -host 69.163.223.11 gw $VPNGW
route add -host 69.163.224.254 gw $VPNGW
route add -host 69.163.232.239 gw $VPNGW
route add -host 69.163.242.152 gw $VPNGW
route add -host 69.163.249.178 gw $VPNGW
route add -host 69.171.229.16 gw $VPNGW
route add -host 69.171.233.18 gw $VPNGW
route add -host 69.171.234.21 gw $VPNGW
route add -host 69.171.237.16 gw $VPNGW
route add -host 69.171.247.21 gw $VPNGW
route add -host 69.172.200.91 gw $VPNGW
route add -host 69.191.215.14 gw $VPNGW
route add -host 69.191.242.22 gw $VPNGW
route add -host 69.191.252.14 gw $VPNGW
route add -host 69.197.153.220 gw $VPNGW
route add -host 69.197.183.149 gw $VPNGW
route add -host 69.20.11.136 gw $VPNGW
route add -host 69.25.102.7 gw $VPNGW
route add -host 69.25.27.173 gw $VPNGW
route add -host 69.26.170.8 gw $VPNGW
route add -host 69.28.65.65 gw $VPNGW
route add -host 69.31.136.5 gw $VPNGW
route add -host 69.36.241.244 gw $VPNGW
route add -host 69.42.223.57 gw $VPNGW
route add -host 69.44.181.242 gw $VPNGW
route add -host 69.46.68.82 gw $VPNGW
route add -host 69.46.91.229 gw $VPNGW
route add -host 69.56.187.226 gw $VPNGW
route add -host 69.59.151.152 gw $VPNGW
route add -host 69.65.24.114 gw $VPNGW
route add -host 69.65.42.159 gw $VPNGW
route add -host 69.65.60.129 gw $VPNGW
route add -host 69.72.177.140 gw $VPNGW
route add -host 69.73.138.107 gw $VPNGW
route add -host 69.89.21.86 gw $VPNGW
route add -host 69.89.29.106 gw $VPNGW
route add -host 69.93.115.144 gw $VPNGW
route add -host 69.93.206.250 gw $VPNGW
route add -host 70.26.54.222 gw $VPNGW
route add -host 70.32.107.173 gw $VPNGW
route add -host 70.32.76.212 gw $VPNGW
route add -host 70.32.81.66 gw $VPNGW
route add -host 70.32.96.58 gw $VPNGW
route add -host 70.37.162.207 gw $VPNGW
route add -host 70.39.67.77 gw $VPNGW
route add -host 70.39.99.91 gw $VPNGW
route add -host 70.42.185.10 gw $VPNGW
route add -host 70.85.21.48 gw $VPNGW
route add -host 70.85.48.246 gw $VPNGW
route add -host 70.86.20.29 gw $VPNGW
route add -host 70.86.57.178 gw $VPNGW
route add -host 70.87.59.134 gw $VPNGW
route add -host 71.245.120.18 gw $VPNGW
route add -host 72.13.82.90 gw $VPNGW
route add -host 72.14.185.130 gw $VPNGW
route add -host 72.14.203.121 gw $VPNGW
route add -host 72.20.18.52 gw $VPNGW
route add -host 72.21.203.211 gw $VPNGW
route add -host 72.21.206.80 gw $VPNGW
route add -host 72.21.210.29 gw $VPNGW
route add -host 72.232.160.83 gw $VPNGW
route add -host 72.233.119.202 gw $VPNGW
route add -host 72.233.2.58 gw $VPNGW
route add -host 72.233.69.6 gw $VPNGW
route add -host 72.249.109.102 gw $VPNGW
route add -host 72.249.186.50 gw $VPNGW
route add -host 72.249.5.110 gw $VPNGW
route add -host 72.26.228.26 gw $VPNGW
route add -host 72.29.65.136 gw $VPNGW
route add -host 72.32.120.222 gw $VPNGW
route add -host 72.32.196.156 gw $VPNGW
route add -host 72.32.231.8 gw $VPNGW
route add -host 72.44.63.18 gw $VPNGW
route add -host 72.52.77.3 gw $VPNGW
route add -host 72.9.144.165 gw $VPNGW
route add -host 74.112.130.78 gw $VPNGW
route add -host 74.113.233.128 gw $VPNGW
route add -host 74.117.221.72 gw $VPNGW
route add -host 74.120.244.228 gw $VPNGW
route add -host 74.121.196.42 gw $VPNGW
route add -host 74.124.208.14 gw $VPNGW
route add -host 74.125.127.100 gw $VPNGW
route add -host 74.125.45.100 gw $VPNGW
route add -host 74.125.53.121 gw $VPNGW
route add -host 74.125.67.100 gw $VPNGW
route add -host 74.125.71.121 gw $VPNGW
route add -host 74.200.220.215 gw $VPNGW
route add -host 74.200.243.251 gw $VPNGW
route add -host 74.200.244.59 gw $VPNGW
route add -host 74.201.86.21 gw $VPNGW
route add -host 74.208.10.7 gw $VPNGW
route add -host 74.208.110.59 gw $VPNGW
route add -host 74.208.17.142 gw $VPNGW
route add -host 74.208.186.70 gw $VPNGW
route add -host 74.208.218.82 gw $VPNGW
route add -host 74.208.228.201 gw $VPNGW
route add -host 74.208.31.254 gw $VPNGW
route add -host 74.208.36.253 gw $VPNGW
route add -host 74.208.62.234 gw $VPNGW
route add -host 74.220.201.139 gw $VPNGW
route add -host 74.220.215.227 gw $VPNGW
route add -host 74.3.160.95 gw $VPNGW
route add -host 74.3.235.18 gw $VPNGW
route add -host 74.50.3.52 gw $VPNGW
route add -host 74.52.140.155 gw $VPNGW
route add -host 74.52.63.28 gw $VPNGW
route add -host 74.53.243.114 gw $VPNGW
route add -host 74.54.139.178 gw $VPNGW
route add -host 74.54.30.85 gw $VPNGW
route add -host 74.55.75.54 gw $VPNGW
route add -host 74.55.98.186 gw $VPNGW
route add -host 74.63.80.66 gw $VPNGW
route add -host 74.82.173.199 gw $VPNGW
route add -host 74.82.179.10 gw $VPNGW
route add -host 74.86.123.132 gw $VPNGW
route add -host 74.86.142.3 gw $VPNGW
route add -host 75.101.145.87 gw $VPNGW
route add -host 75.101.155.42 gw $VPNGW
route add -host 75.101.163.44 gw $VPNGW
route add -host 75.119.196.136 gw $VPNGW
route add -host 75.119.198.245 gw $VPNGW
route add -host 75.119.202.194 gw $VPNGW
route add -host 75.119.205.36 gw $VPNGW
route add -host 75.119.223.191 gw $VPNGW
route add -host 75.125.11.11 gw $VPNGW
route add -host 75.125.244.150 gw $VPNGW
route add -host 75.125.252.77 gw $VPNGW
route add -host 75.126.178.177 gw $VPNGW
route add -host 75.126.182.36 gw $VPNGW
route add -host 75.126.199.99 gw $VPNGW
route add -host 75.98.17.24 gw $VPNGW
route add -host 76.103.88.99 gw $VPNGW
route add -host 76.12.10.110 gw $VPNGW
route add -host 76.73.40.250 gw $VPNGW
route add -host 76.73.45.186 gw $VPNGW
route add -host 76.73.67.28 gw $VPNGW
route add -host 76.74.255.116 gw $VPNGW
route add -host 77.238.178.122 gw $VPNGW
route add -host 77.247.178.32 gw $VPNGW
route add -host 77.247.179.176 gw $VPNGW
route add -host 77.87.181.63 gw $VPNGW
route add -host 78.140.150.140 gw $VPNGW
route add -host 78.16.49.15 gw $VPNGW
route add -host 78.46.38.91 gw $VPNGW
route add -host 8.18.200.7 gw $VPNGW
route add -host 8.23.224.110 gw $VPNGW
route add -host 8.254.61.126 gw $VPNGW
route add -host 80.94.76.5 gw $VPNGW
route add -host 81.169.149.84 gw $VPNGW
route add -host 81.177.139.23 gw $VPNGW
route add -host 82.147.11.31 gw $VPNGW
route add -host 82.195.75.101 gw $VPNGW
route add -host 83.138.187.34 gw $VPNGW
route add -host 83.169.41.77 gw $VPNGW
route add -host 83.222.126.242 gw $VPNGW
route add -host 84.16.80.73 gw $VPNGW
route add -host 84.16.92.183 gw $VPNGW
route add -host 84.45.63.21 gw $VPNGW
route add -host 85.10.213.97 gw $VPNGW
route add -host 85.17.153.54 gw $VPNGW
route add -host 85.17.25.118 gw $VPNGW
route add -host 85.17.27.208 gw $VPNGW
route add -host 85.214.105.129 gw $VPNGW
route add -host 85.214.130.224 gw $VPNGW
route add -host 85.214.153.59 gw $VPNGW
route add -host 85.214.18.161 gw $VPNGW
route add -host 85.214.47.70 gw $VPNGW
route add -host 85.233.202.178 gw $VPNGW
route add -host 86.59.30.40 gw $VPNGW
route add -host 87.106.116.167 gw $VPNGW
route add -host 87.106.148.28 gw $VPNGW
route add -host 87.248.120.148 gw $VPNGW
route add -host 87.255.36.131 gw $VPNGW
route add -host 87.98.250.193 gw $VPNGW
route add -host 88.151.243.8 gw $VPNGW
route add -host 88.86.118.186 gw $VPNGW
route add -host 89.151.116.55 gw $VPNGW
route add -host 89.238.130.247 gw $VPNGW
route add -host 91.121.145.34 gw $VPNGW
route add -host 91.121.182.159 gw $VPNGW
route add -host 91.121.27.37 gw $VPNGW
route add -host 91.207.59.161 gw $VPNGW
route add -host 93.184.216.229 gw $VPNGW
route add -host 93.186.115.3 gw $VPNGW
route add -host 93.186.117.117 gw $VPNGW
route add -host 93.95.227.222 gw $VPNGW
route add -host 94.136.55.26 gw $VPNGW
route add -host 94.76.239.85 gw $VPNGW
route add -host 95.174.9.211 gw $VPNGW
route add -host 95.211.143.200 gw $VPNGW
route add -host 95.211.147.210 gw $VPNGW
route add -host 95.211.200.37 gw $VPNGW
route add -host 95.211.99.2 gw $VPNGW
route add -host 96.125.170.168 gw $VPNGW
route add -host 96.126.120.207 gw $VPNGW
route add -host 96.127.180.202 gw $VPNGW
route add -host 96.30.24.127 gw $VPNGW
route add -host 96.44.129.122 gw $VPNGW
route add -host 96.44.155.216 gw $VPNGW
route add -host 96.44.177.94 gw $VPNGW
route add -host 96.44.184.110 gw $VPNGW
route add -host 96.44.185.116 gw $VPNGW
route add -host 96.46.7.187 gw $VPNGW
route add -host 98.124.198.1 gw $VPNGW
route add -host 98.124.199.1 gw $VPNGW
route add -host 98.129.126.138 gw $VPNGW
route add -host 98.129.174.16 gw $VPNGW
route add -host 98.129.178.208 gw $VPNGW
route add -host 98.130.128.34 gw $VPNGW
route add -host 98.136.60.143 gw $VPNGW
route add -host 98.136.92.79 gw $VPNGW
route add -host 98.137.133.178 gw $VPNGW
route add -host 98.137.46.72 gw $VPNGW
route add -host 98.139.102.145 gw $VPNGW
route add -host 98.139.84.189 gw $VPNGW
route add -host 98.143.152.26 gw $VPNGW
route add -host 99.192.218.36 gw $VPNGW
route add -host 99.231.89.35 gw $VPNGW
route add -net 103.11.213.0/24 gw $VPNGW
route add -net 103.23.108.0/24 gw $VPNGW
route add -net 106.187.34.0/24 gw $VPNGW
route add -net 106.187.35.0/24 gw $VPNGW
route add -net 106.187.61.0/24 gw $VPNGW
route add -net 108.162.193.0/24 gw $VPNGW
route add -net 108.162.194.0/24 gw $VPNGW
route add -net 108.162.195.0/24 gw $VPNGW
route add -net 108.162.196.0/24 gw $VPNGW
route add -net 108.162.198.0/24 gw $VPNGW
route add -net 108.162.199.0/24 gw $VPNGW
route add -net 108.162.233.0/24 gw $VPNGW
route add -net 108.62.192.0/24 gw $VPNGW
route add -net 110.45.152.0/24 gw $VPNGW
route add -net 111.92.237.0/24 gw $VPNGW
route add -net 116.251.204.0/24 gw $VPNGW
route add -net 118.142.53.0/24 gw $VPNGW
route add -net 118.151.231.0/24 gw $VPNGW
route add -net 123.242.230.0/24 gw $VPNGW
route add -net 124.40.41.0/24 gw $VPNGW
route add -net 125.56.218.0/24 gw $VPNGW
route add -net 127.0.0.0/24 gw $VPNGW
route add -net 128.241.116.0/24 gw $VPNGW
route add -net 137.227.232.0/24 gw $VPNGW
route add -net 137.227.241.0/24 gw $VPNGW
route add -net 137.227.252.0/24 gw $VPNGW
route add -net 140.112.172.0/24 gw $VPNGW
route add -net 141.101.124.0/24 gw $VPNGW
route add -net 141.101.126.0/24 gw $VPNGW
route add -net 141.8.224.0/24 gw $VPNGW
route add -net 149.48.228.0/24 gw $VPNGW
route add -net 152.19.134.0/24 gw $VPNGW
route add -net 157.166.226.0/24 gw $VPNGW
route add -net 157.166.248.0/24 gw $VPNGW
route add -net 157.166.249.0/24 gw $VPNGW
route add -net 157.166.255.0/24 gw $VPNGW
route add -net 173.193.161.0/24 gw $VPNGW
route add -net 173.194.72.0/24 gw $VPNGW
route add -net 173.212.56.0/24 gw $VPNGW
route add -net 173.236.243.0/24 gw $VPNGW
route add -net 173.245.60.0/24 gw $VPNGW
route add -net 173.245.61.0/24 gw $VPNGW
route add -net 173.254.28.0/24 gw $VPNGW
route add -net 174.120.113.0/24 gw $VPNGW
route add -net 174.127.195.0/24 gw $VPNGW
route add -net 174.36.20.0/24 gw $VPNGW
route add -net 188.132.190.0/24 gw $VPNGW
route add -net 195.189.143.0/24 gw $VPNGW
route add -net 195.8.215.0/24 gw $VPNGW
route add -net 198.62.75.0/24 gw $VPNGW
route add -net 199.27.134.0/24 gw $VPNGW
route add -net 199.27.135.0/24 gw $VPNGW
route add -net 199.47.216.0/24 gw $VPNGW
route add -net 199.47.217.0/24 gw $VPNGW
route add -net 199.59.148.0/24 gw $VPNGW
route add -net 199.59.149.0/24 gw $VPNGW
route add -net 199.59.150.0/24 gw $VPNGW
route add -net 199.66.238.0/24 gw $VPNGW
route add -net 199.7.177.0/24 gw $VPNGW
route add -net 202.130.82.0/24 gw $VPNGW
route add -net 202.181.198.0/24 gw $VPNGW
route add -net 202.248.110.0/24 gw $VPNGW
route add -net 202.39.235.0/24 gw $VPNGW
route add -net 202.60.254.0/24 gw $VPNGW
route add -net 203.174.49.0/24 gw $VPNGW
route add -net 203.215.253.0/24 gw $VPNGW
route add -net 203.69.42.0/24 gw $VPNGW
route add -net 203.69.66.0/24 gw $VPNGW
route add -net 203.77.188.0/24 gw $VPNGW
route add -net 203.84.197.0/24 gw $VPNGW
route add -net 203.85.62.0/24 gw $VPNGW
route add -net 204.74.212.0/24 gw $VPNGW
route add -net 205.196.120.0/24 gw $VPNGW
route add -net 207.162.210.0/24 gw $VPNGW
route add -net 207.198.113.0/24 gw $VPNGW
route add -net 208.109.138.0/24 gw $VPNGW
route add -net 208.43.212.0/24 gw $VPNGW
route add -net 208.43.60.0/24 gw $VPNGW
route add -net 208.46.163.0/24 gw $VPNGW
route add -net 208.48.81.0/24 gw $VPNGW
route add -net 208.69.40.0/24 gw $VPNGW
route add -net 208.80.154.0/24 gw $VPNGW
route add -net 208.80.184.0/24 gw $VPNGW
route add -net 208.88.180.0/24 gw $VPNGW
route add -net 208.94.0.0/24 gw $VPNGW
route add -net 208.94.146.0/24 gw $VPNGW
route add -net 208.94.147.0/24 gw $VPNGW
route add -net 208.94.241.0/24 gw $VPNGW
route add -net 208.96.32.0/24 gw $VPNGW
route add -net 209.133.27.0/24 gw $VPNGW
route add -net 209.162.253.0/24 gw $VPNGW
route add -net 210.242.17.0/24 gw $VPNGW
route add -net 210.242.234.0/24 gw $VPNGW
route add -net 210.243.166.0/24 gw $VPNGW
route add -net 210.244.31.0/24 gw $VPNGW
route add -net 211.72.248.0/24 gw $VPNGW
route add -net 213.52.252.0/24 gw $VPNGW
route add -net 216.104.165.0/24 gw $VPNGW
route add -net 216.146.46.0/24 gw $VPNGW
route add -net 216.155.135.0/24 gw $VPNGW
route add -net 216.24.199.0/24 gw $VPNGW
route add -net 216.34.181.0/24 gw $VPNGW
route add -net 220.228.147.0/24 gw $VPNGW
route add -net 23.19.35.0/24 gw $VPNGW
route add -net 23.19.81.0/24 gw $VPNGW
route add -net 27.98.194.0/24 gw $VPNGW
route add -net 31.222.72.0/24 gw $VPNGW
route add -net 31.222.74.0/24 gw $VPNGW
route add -net 38.101.236.0/24 gw $VPNGW
route add -net 38.229.72.0/24 gw $VPNGW
route add -net 4.28.99.0/24 gw $VPNGW
route add -net 50.112.141.0/24 gw $VPNGW
route add -net 50.112.148.0/24 gw $VPNGW
route add -net 50.23.200.0/24 gw $VPNGW
route add -net 59.152.227.0/24 gw $VPNGW
route add -net 59.188.18.0/24 gw $VPNGW
route add -net 60.199.245.0/24 gw $VPNGW
route add -net 61.200.81.0/24 gw $VPNGW
route add -net 61.31.212.0/24 gw $VPNGW
route add -net 61.63.52.0/24 gw $VPNGW
route add -net 64.13.192.0/24 gw $VPNGW
route add -net 64.15.205.0/24 gw $VPNGW
route add -net 64.237.33.0/24 gw $VPNGW
route add -net 64.237.47.0/24 gw $VPNGW
route add -net 64.71.141.0/24 gw $VPNGW
route add -net 64.71.33.0/24 gw $VPNGW
route add -net 64.74.223.0/24 gw $VPNGW
route add -net 65.49.2.0/24 gw $VPNGW
route add -net 65.49.26.0/24 gw $VPNGW
route add -net 65.49.68.0/24 gw $VPNGW
route add -net 66.147.242.0/24 gw $VPNGW
route add -net 66.147.244.0/24 gw $VPNGW
route add -net 66.96.130.0/24 gw $VPNGW
route add -net 66.96.131.0/24 gw $VPNGW
route add -net 67.23.129.0/24 gw $VPNGW
route add -net 68.178.232.0/24 gw $VPNGW
route add -net 68.233.230.0/24 gw $VPNGW
route add -net 69.163.141.0/24 gw $VPNGW
route add -net 69.163.142.0/24 gw $VPNGW
route add -net 69.167.127.0/24 gw $VPNGW
route add -net 69.175.106.0/24 gw $VPNGW
route add -net 69.43.161.0/24 gw $VPNGW
route add -net 69.55.53.0/24 gw $VPNGW
route add -net 69.89.31.0/24 gw $VPNGW
route add -net 72.12.215.0/24 gw $VPNGW
route add -net 72.172.88.0/24 gw $VPNGW
route add -net 72.233.104.0/24 gw $VPNGW
route add -net 72.52.124.0/24 gw $VPNGW
route add -net 72.52.81.0/24 gw $VPNGW
route add -net 74.117.178.0/24 gw $VPNGW
route add -net 74.120.121.0/24 gw $VPNGW
route add -net 74.122.174.0/24 gw $VPNGW
route add -net 74.125.31.0/24 gw $VPNGW
route add -net 74.200.247.0/24 gw $VPNGW
route add -net 74.201.154.0/24 gw $VPNGW
route add -net 74.206.187.0/24 gw $VPNGW
route add -net 74.220.199.0/24 gw $VPNGW
route add -net 74.220.207.0/24 gw $VPNGW
route add -net 74.53.4.0/24 gw $VPNGW
route add -net 76.74.159.0/24 gw $VPNGW
route add -net 76.74.254.0/24 gw $VPNGW
route add -net 78.109.93.0/24 gw $VPNGW
route add -net 78.129.203.0/24 gw $VPNGW
route add -net 8.27.235.0/24 gw $VPNGW
route add -net 8.27.248.0/24 gw $VPNGW
route add -net 8.5.1.0/24 gw $VPNGW
route add -net 80.239.151.0/24 gw $VPNGW
route add -net 82.98.86.0/24 gw $VPNGW
route add -net 84.20.200.0/24 gw $VPNGW
route add -net 85.17.216.0/24 gw $VPNGW
route add -net 88.208.24.0/24 gw $VPNGW
route add -net 89.238.136.0/24 gw $VPNGW
route add -net 89.238.161.0/24 gw $VPNGW
route add -net 92.61.153.0/24 gw $VPNGW
route add -net 93.170.52.0/24 gw $VPNGW
route add -net 97.74.144.0/24 gw $VPNGW
route add -net 97.74.215.0/24 gw $VPNGW
route add -net 98.129.229.0/24 gw $VPNGW
route add -net 98.139.135.0/24 gw $VPNGW
##### end batch route #####


echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") loading vpnup_custom if available" >> $LOG
export VPNGW=$VPNGW
export OLDGW=$OLDGW
grep ^route $VPNUPCUSTOM  | /bin/sh -x

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
