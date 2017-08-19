#!/bin/bash
# author: chat@jat.email

./build.py "$HOSTSITE"

./qshell account "$QINIU_AK" "$QINIU_SK"
sed -i "s/#QINIU_BUCKET#/$QINIU_BUCKET/" .qupload.json

mkdir list
i=1

while :; do
    ./qshell qupload -success-list list/success_$i.txt -overwrite-list list/overwrite_$i.txt "$(find build -type f | wc -l)" .qupload.json && break
    ((i++))
done

for f in list/*; do
    sed -ri "s#[^\t]+\t#$HOSTSITE/#" "$f"
    cat "$f"
    while :; do ./qshell cdnrefresh "$f" && break; done
done
