#!/usr/bin/python

import json
import sys
from collections import OrderedDict
from copy import deepcopy

inFile = json.loads(open(sys.argv[1], 'r').read(), object_pairs_hook=OrderedDict)
inKeys = inFile.keys()

fileList = sys.argv[2:]
for f in fileList:
    f = json.loads(open(f,'r').read())
    fKeys = f.keys()
    for key in fKeys:
        if key in inKeys:
            inFile[key] += f[key]
        else:
            inFile[key] = f[key]
print json.dumps(inFile,indent=4)

