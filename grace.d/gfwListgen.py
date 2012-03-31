#!/usr/bin/env python

import urllib
import base64
import string
#from socket import gethostbyname
import dns.resolver
import re

gfwlist = 'http://autoproxy-gfwlist.googlecode.com/svn/trunk/gfwlist.txt'
oklist = ['flickr.com']
print "fetching gfwList ..."
d = urllib.urlopen(gfwlist).read()
#d = open('gfwlist.txt').read()
data = base64.b64decode(d)
#fd = open('gfwlist','w')
#fd.write(data)
#fd.close()
lines = string.split(data, "\n")
newlist = []

def isipaddr(hostname=''):
	pat = re.compile(r'[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
	if re.match(pat, hostname):
		return 0
	else:
		return -1

def getip(hostname=''):
	_ip = []
	if isipaddr(hostname) == 0:
		print hostname + " is IP address"
		_ip.append(hostname)
		return
	r = dns.resolver.get_default_resolver()
	r.nameservers=['8.8.8.8']
	#answers = dns.resolver.query(hostname, 'A')
	try:
		answers = r.query(hostname, 'A')
		for rdata in answers:
			print rdata.address
			_ip.append(rdata.address)
	except dns.resolver.NoAnswer:
		print "no answer"

	if hostname.find("www.") != 0:
		hostname = "www."+hostname
		print "querying "+hostname
		try:
			answers = dns.resolver.query(hostname, 'A')
			for rdata in answers:
				print rdata.address
				_ip.append(rdata.address)
		except dns.resolver.NoAnswer:
			print "no answer"
		
	return list(set(_ip))

for l in lines:
		if len(l) == 0:
			continue
		if l[0] == "!":
			continue
		if l[0] == "|":
			continue
		if l[0] == "@":
			continue
		if l[0] == "[":
			continue
		if l.find('zh.wikipedia.org') == 0:
			continue
		l = string.replace(l, "||","").lstrip(".")
		# strip everything from "/" to the end
		if l.find("/") != -1:
			l = l[0:l.find("/")]
		if l.find("*") != -1:
			continue
		if l.find(".") == -1:
			continue
		if l in oklist:
			continue
		newlist.append(l)

known_list = [ x.rstrip() for x in open('known_gfw_domains').readlines() ]
#newlist.append('zh.wikipedia.org')
newlist.extend(known_list)
newlist = list(set(newlist))
newlist.sort()
#print newlist
ip = []
count=0
gfwdn = open('gfwdomains', 'wa')
for l in newlist:
	#if count>10: break
	print l
	gfwdn.write('server=/'+l+'/8.8.8.8\n')
	try:
		myip = getip(l)
		ip+=myip
		count+=1
	except:
		continue

gfwdn.close()

iplist = list(set(ip))
iplist.sort()
#print ip
#ipfd = open("ip-list","wa")
#for i in iplist:
	#print i
	#ipfd.write(i+"\n")
#ipfd.close()
	


subnetdir={}
for ip in iplist:
	(a,b,c,d) = string.split(ip, ".")
	subnet = a+"."+b+"."+c+".0"
	if subnetdir.has_key(subnet):
		subnetdir[subnet]+=1
	else:
		subnetdir[subnet]=1

msubnet=[]
for subnet in subnetdir.keys():
	if subnetdir[subnet]>1:
		msubnet.append(subnet)
		#print subnet+"/24"

ipaddrlist = []
for ip in iplist:
	(a,b,c,d) = string.split(ip, ".")
	_subnet = a+"."+b+"."+c+".0"
	if _subnet in msubnet:
		print "%s is in subnet %s" % (ip, _subnet)
	else:
		print "%s has no subnet available" % (ip)
		ipaddrlist.append(ip)

ipaddrlist.sort()
msubnet.sort()
#for i in ipaddrlist:
	#print "route add -host %s gw $VPNGW" % i
#for m in msubnet:
	#print "route add -net %s/24 gw $VPNGW" % m
	
#####
#####
#####

up="http://autoddvpn.googlecode.com/svn/trunk/grace.d/vpnup.sh"
#down="http://autoddvpn.googlecode.com/svn/trunk/vpndown.sh"

upfile=open('vpnup-grace.sh','wa')


print "[INFO] fetching the latest grace mode vpnup.sh from SVN over http"
uplines = urllib.urlopen(up).readlines()
#uplines = open('vpnup.sh').readlines()

# count the current route lines
for l in range(len(uplines)):
	if uplines[l].find('all others') != -1:
		oldcnt_s = l
	if uplines[l].find('end batch route') != -1:
		oldcnt_e = l
oldcnt = oldcnt_e - oldcnt_s - 1

#print "[INFO] %i routes exists on the SVN" % oldcnt

#
# for the vpnup.sh, write everything just as before 'all others'
#
_anchor=0
for l in uplines:
	#if _anchor==0:	print l.rstrip()
	if _anchor==0:	upfile.write(l)
	if l.find('all others') != -1:
		break

#print "[INFO] getting the IP list from c, this may take a while."
#lstlines = open('country-ipv4.lst').readlines()
#lstlines = urllib.urlopen(ipv4url).readlines()
#lstlines = open('c').readlines()
print "[INFO] generating the routes"
cnt=0
for i in ipaddrlist:
	buff = "route add -host %s gw $VPNGW" % i
	print buff
	upfile.write(buff+'\n')
	cnt+=1
for m in msubnet:
	buff = "route add -net %s/24 gw $VPNGW" % m
	print buff
	upfile.write(buff+'\n')
	cnt+=1

#for l in lstlines:
	#upfile.write(l)
	#cnt+=1

#print "[INFO] total %i routes generated(%i route(s) added)" % (cnt, cnt-oldcnt)

#
# for the vpnup.sh, write everything just as after 'end batch route'
#
_anchor=0
for l in uplines:
	#if _anchor==1:	print l.rstrip()
	if _anchor==1:	upfile.write(l)
	if l.find('end batch route') != -1:
		#print l.rstrip()
		upfile.write(l)
		_anchor=1

upfile.close()
#downfile.close()
print "[INFO] ALL DONE"
#print "[INFO] remember to chmod +x vpnup.sh vpndown.sh"
