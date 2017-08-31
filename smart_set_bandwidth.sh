#!/bin/bash

BW=`zabbix_get  -s CLIENT_IP -k net.if.out[tun0]`
#2 minutes
INTERVAL=120
SPEED=41 #about equal 4.0MBps bandwidth

function ten {
	TOKEN=`/usr/bin/curl -H 'username:XXX' -H 'password:XXXX' http://api.yun-idc.com/gic/v1/get_token/|awk '{print $4}'|sed 's/}//'|sed 's/"//g'`
	sleep 1
	/usr/bin/curl -XPOST -d '{"qos":10}' -H "token:$TOKEN" http://api.yun-idc.com/gic/v1/public/update/YOUR_PUBLIC_ID
}


function five {
	TOKEN=`/usr/bin/curl -H 'username:XXX' -H 'password:XXX' http://api.yun-idc.com/gic/v1/get_token/|awk '{print $4}'|sed 's/}//'|sed 's/"//g'`
	sleep 1
	/usr/bin/curl -XPOST -d '{"qos":5}' -H "token:$TOKEN" http://api.yun-idc.com/gic/v1/public/update/YOUR_PUBLIC_ID
}

function check {
	TOKEN=`/usr/bin/curl -H 'username:XXX' -H 'password:XXX' http://api.yun-idc.com/gic/v1/get_token/|awk '{print $4}'|sed 's/}//'|sed 's/"//g'`
	sleep 1
	NUM=`curl -H "token:$TOKEN" http://api.yun-idc.com/gic/v1/bandwidth/public/YOUR_PUBLIC_ID|grep "qos"|awk -F: '{print $NF}'|sed 's/}//'|sed 's/ //'`

}

[ -z /tmp/bw ] && exit 1
[ -z /tmp/result ] && exit 1
LASTRESULT=`cat /tmp/bw`
RESULT=`echo "($BW-$LASTRESULT)*8/100000/$INTERVAL"|bc`
if [ $RESULT -gt $SPEED ];then
	if [ `cat /tmp/result` -lt $SPEED ];then
		check
		if [ $NUM -eq 5 ];then
			ten
		fi
	fi
else
	if [ `cat /tmp/result` -gt $SPEED ];then
		check
		if [ $NUM -eq 10 ];then
			five
		fi
	fi
fi

echo $BW > /tmp/bw
echo $RESULT > /tmp/result
