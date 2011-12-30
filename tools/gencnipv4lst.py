#!/usr/bin/env python

import urllib
import urllib2
import string
import re
import math

#ipv4url='http://ftp.apnic.net/apnic/dbase/data/country-ipv4.lst'
ipv4url='http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest'
up="http://autoddvpn.googlecode.com/svn/trunk/vpnup.sh"
down="http://autoddvpn.googlecode.com/svn/trunk/vpndown.sh"

upfile=open('vpnup.sh','wa')
downfile=open('vpndown.sh','wa')

def fetch_ip_data():
  """ by http://chnroutes.googlecode.com/svn/trunk/chnroutes.py """
  #fetch data from apnic
  print "Fetching data from apnic.net, it might take a few minutes, please wait..."
  url=r'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest'
  data=urllib2.urlopen(url).read()
  
  cnregex=re.compile(r'apnic\|cn\|ipv4\|[0-9\.]+\|[0-9]+\|[0-9]+\|a.*',re.IGNORECASE)
  cndata=cnregex.findall(data)
  
  results=[]

  for item in cndata:
      unit_items=item.split('|')
      starting_ip=unit_items[3]
      num_ip=int(unit_items[4])
      
      imask=0xffffffff^(num_ip-1)
      #convert to string
      imask=hex(imask)[2:]
      mask=[0]*4
      mask[0]=imask[0:2]
      mask[1]=imask[2:4]
      mask[2]=imask[4:6]
      mask[3]=imask[6:8]
      
      #convert str to int
      mask=[ int(i,16 ) for i in mask]
      mask="%d.%d.%d.%d"%tuple(mask)
      
      #mask in *nix format
      mask2=32-int(math.log(num_ip,2))
      
      results.append((starting_ip,mask,mask2))
       
  return results


def main():
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

	#print "[INFO] getting the IP list from APNIC, this may take a while."
	#lstlines = open('country-ipv4.lst').readlines()
	#lstlines = urllib.urlopen(ipv4url).readlines()
	print "[INFO] generating the routes"
	cnt=0
	results = fetch_ip_data()
	for ip,mask,_ in results:
		#print "route add -net %s netmask %s gw $OLDGW" % (ip, mask)
		upfile.write("route add -net %s/%s gw $OLDGW\n" % (ip, mask))
		downfile.write("route del -net %s/%s\n" % (ip, mask))
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
			_anchor=1
			#print l.rstrip()
			downfile.write(l)

	upfile.close()
	downfile.close()
	print "[INFO] ALL DONE"
	print "[INFO] remember to chmod +x vpnup.sh vpndown.sh"

if __name__ == '__main__':
	main()
