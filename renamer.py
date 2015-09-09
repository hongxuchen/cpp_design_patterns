#!/usr/bin/env python

from __future__ import print_function
import os
import sys

root = os.path.abspath(os.getcwd())
if len(sys.argv) == 2:
    if os.path.isdir(sys.argv[1]):
        root = sys.argv[1]
print('root dir is [{}]'.format(root))
for r, dirs, files in os.walk(root):
    for f in files:
        fpath = os.path.join(r, f)
        print(fpath)
        path_prefix, ext = os.path.splitext(fpath)
        if ext == '.hpp':
            new_fpath = path_prefix + '.hh'
            print('{}->{}'.format(fpath, new_fpath))
            os.rename(fpath, new_fpath)
