#!/bin/sh
# Copyright (C) 2016 Simon Mbuthia [http://github.com/Saichovsky]

PROXYLIST=~/proxies; : > $PROXYLIST
TS=`date +"%F %T"`
C=0
WGET="wget -q -O - --header=\"Accept: text/html\" --user-agent=\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:21.0) Gecko/20100101 Firefox/21.0\""
printf "%s - Attempting to retrieve from proxydb.net... " "$TS"
BUF=`${WGET} 'http://proxydb.net/?protocol=socks5&anonlvl=2&anonlvl=3&anonlvl=4&response_time=5&availability=30'`
# LIST=`${WGET} 'http://proxydb.net/?protocol=socks5&anonlvl=2&anonlvl=3&anonlvl=4&response_time=5&offset=$C' | grep -osP '(\d+\.\d+\.\d+\.\d+:\d+)'`
LIST=`echo $BUF | grep -osP '(\d+\.\d+\.\d+\.\d+:\d+)'`
PROXIES=`echo $BUF | grep -oP "(?<=Found )\d+(?= proxies)"`
C=`echo $LIST | wc -w`

if [ $C -gt 0 ]; then
  while [ $C -lt $PROXIES ]; do
    echo "$TS - Sleeping..."
    sleep 5
    LIST="$LIST `${WGET} \"http://proxydb.net/?protocol=socks5&anonlvl=2&anonlvl=3&anonlvl=4&response_time=5&availability=30&offset=$C\" | \
        grep -oP '(\d+\.\d+\.\d+\.\d+:\d+)'`"
    C=`echo $LIST | wc -w`
  done
fi
printf "done [%d host(s) fetched].\n%s - Attempting to retrieve from a secondary source... " $C "$TS"

LIST2=`eval ${WGET} 'https://hidemy.name/en/proxy-list/?maxtime=400&type=5&anon=34' | grep -oP '\d+\.\d+\.\d+\.\d+(\<\/?td\>)+\d+' | \
    sed 's,</td><td>,:,g'`
printf "done [`echo $LIST2 | wc -w` host(s) fetched].\n%s - Merging and de-duping into file... " "$TS"
echo "$LIST $LIST2" | sed -r 's/\s+/\n/g' | sort | uniq > $PROXYLIST
echo "done."

if [ `stat -c %s $PROXYLIST` -lt 5 ]; then
    echo "$TS - Looks like no valid proxy servers were found :-("
    exit 2
else
    echo "$TS - Tested and working proxy servers"
    echo "                      ================================"

    while read proxy; do
      HOST=`echo $proxy | cut -d: -f1`
      PORT=`echo $proxy | cut -d: -f2`
      H=`curl --retry 0 -m 15 --retry-max-time 10 -s --socks5-hostname $proxy 'http://www.ip-secrets.com' | \
        grep current | grep -oP "\d+\.\d+\.\d+\.\d+"`
      test -n "$H" && echo "$TS - socks5://${proxy} [seen as $H]" || (sed -i "/$proxy/d;" $PROXYLIST)
    done < $PROXYLIST
    echo "$TS - List stored in $PROXYLIST"
fi
