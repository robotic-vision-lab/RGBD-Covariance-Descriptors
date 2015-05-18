#!/usr/bin/env python
#
# Subsample a set of PCD files from a source directory based on a given 
# sampling rate. 
#
import re
import os
import sys
import shutil

if len(sys.argv) != 4:
    print "Usage: generate_subsample source_dir dest_dir sampling_rate"
    sys.exit()

src_dir = sys.argv[1]
dst_dir = sys.argv[2]
sampling_rate = int(sys.argv[3])

# Create the destination directory
print 'Creating destination directory ...', 
shutil.copytree(src_dir, dst_dir)
print 'done'

# Prune the destination directory
print 'Pruning destination directory ...',
for path, dirs, files in os.walk(dst_dir):
    if len(files):
        for f in files:
            m = re.search('(\d+_(\d+)).pcd', f)
            i = int(m.group(2))
            file = os.path.abspath(os.path.join(path, f))
            if i != 1 and ((i - 1) % sampling_rate) != 0: 
                os.remove(file)
            else:
                dir = os.path.abspath(os.path.join(path, m.group(1)))
                os.mkdir(dir)
                shutil.move(file, dir)
print 'done'
