#!/bin/bash
# author: chat@jat.email

HOSTSITE=${HOSTSITE:-127.0.0.1}
HOSTSITE=${HOSTSITE%/}
[ "${HOSTSITE:0:4}" != 'http' ] && HOSTSITE="http://$HOSTSITE"

mkdir build lists

for f in rules/*; do
    t=${f#rules/}; t=${t%.*}
    sed "s^#hostsite#^$HOSTSITE^" "$f" | base64 -w 0 > "build/$t"
done
date +%s%3N > build/update

./qshell account "$QINIU_AK" "$QINIU_SK"
sed -i "s/#QINIU_BUCKET#/$QINIU_BUCKET/" .qupload.json

i=1
while :; do
    ./qshell qupload -success-list lists/success_$i.txt "$(find build -type f | wc -l)" .qupload.json && break
    ((i++))
done

for f in lists/*; do
    sed -ri "s#[^\t]+\t#$HOSTSITE/#" "$f"
    while :; do ./qshell cdnrefresh "$f" && break; done
done
