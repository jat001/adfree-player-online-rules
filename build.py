#!/usr/bin/env python
# -*- coding: utf-8 -*-
# -*- author: chat@jat.email -*-

import os
import io
import sys
from base64 import b64encode


def safe_list_get(l, i, d=None):
    try:
        return l[i]
    except IndexError:
        return d


def main():
    hostsite = safe_list_get(sys.argv, 1, 'http://127.0.0.1')
    if not hostsite.startswith('http'):
        hostsite = 'http://' + hostsite

    root_dir = safe_list_get(sys.argv, 2, os.path.dirname(os.path.abspath(__file__)))
    rules_dir = os.path.join(root_dir, 'rules')
    build_dir = os.path.join(root_dir, 'build')
    if not os.path.isdir(build_dir):
        os.mkdir(build_dir)

    for i in os.listdir(rules_dir):
        name, ext = i.rsplit('.', 1)
        if ext != 'json':
            continue

        with io.open(os.path.join(rules_dir, i), encoding='utf-8') as rule, \
                io.open(os.path.join(build_dir, name), 'w', encoding='utf-8') as build:
            build.write(b64encode(rule.read().replace('#hostsite#', hostsite).encode('utf-8')).decode('ascii'))


if __name__ == '__main__':
    main()
