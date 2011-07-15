#!/bin/sh
#set -x

host='autoddvpn.googlecode.com'
cv_dir='/jffs/var/'
cv_file="${cv_dir}version.client"
vpnup_remote_path='http://autoddvpn.googlecode.com/svn/trunk/grace.d/vpnup.sh'
vpnup_local_path='/jffs/openvpn/vpnup.sh'

get_server_version() {
	printf "HEAD /svn/trunk/grace.d/vpnup.sh  HTTP/1.0\nHost: $host\n\n"  | \
	nc $host 80 | \
	sed -n 's#^ETag: "\(.*\)//trunk/.*#\1#pg'
}

get_client_version() {
	if [ ! -d $cv_dir ]; then mkdir -p $cv_dir; fi
	if [ ! -e $cv_file ]; then
		cv=0
	else
		cv=$(head -n 1 $cv_file)
	fi
	echo $cv
}

update_vpnup() {
	echo "[INFO] start updating"
	mv ${vpnup_local_path} ${vpnup_local_path}.old
	wget -q ${vpnup_remote_path} -O ${vpnup_local_path}
	chmod a+x ${vpnup_local_path}
}

restart_openvpn() {
	kill -HUP $(pidof openvpn)
	return $?
}


sv=$(get_server_version)
cv=$(get_client_version)

if [ $sv -gt $cv ]; then
	echo "[INFO] need update(client version: $cv is lower than server verson: $sv)"
	update_vpnup
	if [ $? -eq 0 ]; then
		echo $sv > $cv_file
		echo "[OK] update completed"
		restart_openvpn
		if [ $? -eq 0 ]; then
			echo "[OK] OpenVPN restarting and refreshing the routing table now."
			echo "[INFO] this may take a while to apply new rules"
		else
			echo "[ERR] failed to restart the OpenVPN, you may need to reboot DDWRT"
		fi
	else
		echo "[ERR] update failed"
	fi
	
elif [ $sv -eq $cv ]; then
	echo "[INFO] already up-to-date"
else
	echo "[ERR] client version is newer than server version"
fi

