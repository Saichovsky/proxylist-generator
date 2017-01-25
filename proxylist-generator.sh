#!/bin/sh
# Copyright (C) 2016 Simon Mbuthia [http://github.com/Saichovsky]

PROXYLIST=~/proxies; : > $PROXYLIST
OS=0; C=0
WGET="wget -q -O -"
LIST=`${WGET} 'http://proxydb.net/?protocol=socks5&anonlvl=2&anonlvl=3&anonlvl=4&offset=$OS' | grep -oP '(\d+\.\d+\.\d+\.\d+:\d+)'`
if [ -n "$LIST" ]; then
  C=`echo $LIST | sed -r 's/\s+/\n/g' | wc -l`
  while [ `expr $C % 50` -eq 0 ]; do
    OS=$(($OS + 50))
    LIST="$LIST `${WGET} \"http://proxydb.net/?protocol=socks5&anonlvl=2&anonlvl=3&anonlvl=4&offset=$OS\" | \
        grep -oP '(\d+\.\d+\.\d+\.\d+:\d+)'`"
    C=`echo $LIST | sed -r 's/\s+/\n/g; /^\s+$/d' | wc -l`
  done
fi
LIST="$LIST `${WGET} 'https://incloak.com/proxy-list/?maxtime=1500&type=5&anon=4' | \
  grep -oP "\d+\.\d+\.\d+\.\d+(\<\/?td\>)+\d+" | sed 's,</td><td>,:,g'`"
echo $LIST | sed -r 's/\s+/\n/g' | sort | uniq > $PROXYLIST

echo "Tested and working proxy servers"
echo "================================"

while read proxy; do
  HOST=`echo $proxy | cut -d: -f1`
  PORT=`echo $proxy | cut -d: -f2`
  H=`curl --retry 0 -m 15 --retry-max-time 10 -s --socks5-hostname $proxy 'http://www.ip-secrets.com' | \
    grep current | grep -oP "\d+\.\d+\.\d+\.\d+"`
  test -n "$H" && echo "socks5://${proxy} [seen as $H]" || (sed -i "/$proxy/d;" $PROXYLIST)
done < $PROXYLIST
echo "List stored in $PROXYLIST"
