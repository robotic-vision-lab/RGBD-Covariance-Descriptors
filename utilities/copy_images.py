#!/usr/bin/env python
#
# Copy a set of PNG images from one directory to another.
#
import re
import os
import sys
import shutil

# Python Cookbook 4.16
def splitall(path):
    allparts = []
    while 1:
        parts = os.path.split(path)
        if parts[0] == path:  # sentinel for absolute paths
            allparts.insert(0, parts[0])
            break
        elif parts[1] == path: # sentinel for relative paths
            allparts.insert(0, parts[1])
            break
        else:
            path = parts[0]
            allparts.insert(0, parts[1])
    return allparts

if len(sys.argv) != 3:
    print "Usage: copy_images in_dir out_dir"
    sys.exit()

in_dir = sys.argv[1]
out_dir = sys.argv[2]

# Copy images to destination directory
print 'Copying images to destination directory ...',
for path, dirs, files in os.walk(out_dir):
    for d in dirs:
        m = re.search('(\d+_\d+)', d)
        if m:
            parts = splitall(path)
            category = parts[-2]
            instance = parts[-1]
            dst_dir = os.path.abspath(os.path.join(path, m.group(1)))
            img_file1 = os.path.abspath(in_dir + '/' + category + '/' + instance \
                        + '/' + instance + '_' + m.group(1) + '_crop.png')
            img_file2 = os.path.abspath(in_dir + '/' + category + '/' + instance \
                        + '/' + instance + '_' + m.group(1) + '_depthcrop.png')
            shutil.copy(img_file1, dst_dir)
            shutil.copy(img_file2, dst_dir)
print 'done'
