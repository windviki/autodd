#!/usr/bin/env python

import urllib
import string

ipv4url='http://ftp.apnic.net/apnic/dbase/data/country-ipv4.lst'
up="http://autoddvpn.googlecode.com/svn/trunk/vpnup.sh"
down="http://autoddvpn.googlecode.com/svn/trunk/vpndown.sh"

upfile=open('vpnup.sh','wa')
downfile=open('vpndown.sh','wa')


print "[INFO] fetching the latest vpnup.sh from SVN over http"
uplines = urllib.urlopen(up).readlines()
print "[INFO] fetching the latest vpndown.sh from SVN over http"
downlines = urllib.urlopen(down).readlines()

# count the current route lines
for l in range(len(uplines)):
	if uplines[l].find('begin batch route') != -1:
		oldcnt_s = l
	if uplines[l].find('end batch route') != -1:
		oldcnt_e = l
oldcnt = oldcnt_e - oldcnt_s - 1

print "[INFO] %i routes exists on the SVN" % oldcnt

#
# for the vpnup.sh
#
_anchor=0
for l in uplines:
	#if _anchor==0:	print l.rstrip()
	if _anchor==0:	upfile.write(l)
	if l.find('begin batch route') != -1:
		break

#
# for the vpndown.sh
#
_anchor=0
for l in downlines:
	#if _anchor==0:	print l.rstrip()
	if _anchor==0:	downfile.write(l)
	if l.find('begin batch route') != -1:
		break

print "[INFO] getting the IP list from APNIC, this may take a while."
#lstlines = open('country-ipv4.lst').readlines()
lstlines = urllib.urlopen(ipv4url).readlines()
print "[INFO] generating the routes"
cnt=0
for l in lstlines:
	if l.find('cn') != -1:	
		list = string.split(l.rstrip(), " ")
		(ip, mask) = (list[0], list[2])
		#print "route add -net %s netmask %s gw $OLDGW" % (ip, mask)
		upfile.write("route add -net %s netmask %s gw $OLDGW\n" % (ip, mask))
		downfile.write("route del -net %s netmask %s gw $OLDGW\n" % (ip, mask))
		cnt+=1

print "[INFO] total %i routes generated(%i route(s) added)" % (cnt, cnt-oldcnt)

#
# for the vpnup.sh
#
_anchor=0
for l in uplines:
	#if _anchor==1:	print l.rstrip()
	if _anchor==1:	upfile.write(l)
	if l.find('end batch route') != -1:
		#print l.rstrip()
		upfile.write(l)
		_anchor=1

#
# for the vpndown.sh
#
_anchor=0
for l in downlines:
	#if _anchor==1:	print l.rstrip()
	if _anchor==1:	downfile.write(l)
	if l.find('end batch route') != -1:
		#print l.rstrip()
		downfile.write(l)

upfile.close()
downfile.close()
print "[INFO] ALL DONE"
