#!/usr/bin/env python
#
# Divide each video into 3 contiguous sequences of equal length as outlined in 
# "A Large-Scale Hierarchical Multi-View RGB-D Object Dataset" by Lai et al. 
#
import re
import os
import sys
import shutil

if len(sys.argv) != 3:
    print "Usage: divide_subsamples source_dir dest_dir"
    sys.exit()

src_dir = sys.argv[1]
dst_dir = sys.argv[2]

# Create the destination directory
print 'Creating destination directory ...', 
shutil.copytree(src_dir, dst_dir)
print 'done'

# Move subdirectories
print 'Moving directories ...',
for path, dirs, files in os.walk(dst_dir):
    v1 = []
    v2 = []
    v3 = []
    # Collect the subdirectories corresponding to the 3 videos of the current 
    # instance
    for d in dirs:
        m1 = re.search('1_(\d+)', d)  
        m2 = re.search('2_(\d+)', d)  
        m3 = re.search('4_(\d+)', d)  
        dir = os.path.abspath(os.path.join(path, d))
        if m1:
            v1.append([int(m1.group(1)), dir])
        elif m2:
            v2.append([int(m2.group(1)), dir])
        elif m3:
            v3.append([int(m3.group(1)), dir])
    # Divide each video into 3 contiguous sequences of equal length giving
    # 9 video sequences for each instance
    if len(v1):
        v1.sort()
        n = len(v1) / 3
        t1 = v1[:n]
        t2 = v1[n:2*n]
        t3 = v1[2*n:]
        t1_dir = os.path.abspath(os.path.join(path, '1-1'))
        os.mkdir(t1_dir)
        t2_dir = os.path.abspath(os.path.join(path, '1-2'))
        os.mkdir(t2_dir)
        t3_dir = os.path.abspath(os.path.join(path, '1-3'))
        os.mkdir(t3_dir)
        for t in t1:
            t_dir = t[1]
            shutil.move(t_dir, t1_dir)
        for t in t2:
            t_dir = t[1]
            shutil.move(t_dir, t2_dir)
        for t in t3:
            t_dir = t[1]
            shutil.move(t_dir, t3_dir)
    if len(v2):
        v2.sort()
        n = len(v2) / 3
        t1 = v2[:n]
        t2 = v2[n:2*n]
        t3 = v2[2*n:]
        t1_dir = os.path.abspath(os.path.join(path, '2-1'))
        os.mkdir(t1_dir)
        t2_dir = os.path.abspath(os.path.join(path, '2-2'))
        os.mkdir(t2_dir)
        t3_dir = os.path.abspath(os.path.join(path, '2-3'))
        os.mkdir(t3_dir)
        for t in t1:
            t_dir = t[1]
            shutil.move(t_dir, t1_dir)
        for t in t2:
            t_dir = t[1]
            shutil.move(t_dir, t2_dir)
        for t in t3:
            t_dir = t[1]
            shutil.move(t_dir, t3_dir)
    if len(v3):
        v3.sort()
        n = len(v3) / 3
        t1 = v3[:n]
        t2 = v3[n:2*n]
        t3 = v3[2*n:]
        t1_dir = os.path.abspath(os.path.join(path, '3-1'))
        os.mkdir(t1_dir)
        t2_dir = os.path.abspath(os.path.join(path, '3-2'))
        os.mkdir(t2_dir)
        t3_dir = os.path.abspath(os.path.join(path, '3-3'))
        os.mkdir(t3_dir)
        for t in t1:
            t_dir = t[1]
            shutil.move(t_dir, t1_dir)
        for t in t2:
            t_dir = t[1]
            shutil.move(t_dir, t2_dir)
        for t in t3:
            t_dir = t[1]
            shutil.move(t_dir, t3_dir)
print 'done'
