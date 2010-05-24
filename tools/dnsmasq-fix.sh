
dn='facebook.com fbcdn.net twitter.com youtube.com'
query='8.8.8.8'
dnsmasqconf='/tmp/dnsmasq.conf'

if [ -e $dnsmasqconf ]; then
	echo "[INFO] found $dnsmasqconf"
	for d in $dn
	do
		echo "[INFO] fixing for $d"
		echo "server=/$d/$query"  >> $dnsmasqconf
	done
	echo "[INFO] reloading dnsmasq"
	#killall -1 dnsmasq
	killall dnsmasq && dnsmasq --conf-file=/tmp/dnsmasq.conf
else
	echo "[WARN] $dnsmasqconf not found"
fi
