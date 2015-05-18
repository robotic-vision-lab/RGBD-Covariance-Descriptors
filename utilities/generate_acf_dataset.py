#!/usr/bin/env python
#
# Alternating contiguous frames (acf): Randomly select 2 out of 9 video 
# sequences for testing and use the remaining for training as outlined in 
# "A Large-Scale Hierarchical Multi-View RGB-D Object Dataset" by Lai et al.
#
import re
import os
import sys
import shutil
import random

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

if len(sys.argv) != 4:
    print "Usage: generate_acf_dataset source_dir train_dir test_dir"
    sys.exit()

src_dir = sys.argv[1]
train_dir = sys.argv[2]
test_dir = sys.argv[3]

# Create the train and test directories
print 'Creating train directory ...',
os.makedirs(train_dir)
print 'done'
print 'Creating test directory ...',
os.makedirs(test_dir)
print 'done'

# Copy directories
print 'Copying directories ...',
for path1, dirs, files in os.walk(src_dir):
    for d in dirs:
        m = re.search('[a-z]_\d', d)
        if m:
            dir = os.path.abspath(os.path.join(path1, d))
            r1 = random.sample(range(1,4), 2)
            r2 = random.sample(range(1,4), 2)
            test_set_1 = str(r1[0]) + '-' + str(r2[0])
            test_set_2 = str(r1[1]) + '-' + str(r2[1])
            for path2, dirs2, files2 in os.walk(dir):
                for d2 in dirs2:
                    parts = splitall(path2)
                    category = parts[-2]
                    instance = parts[-1]
                    m2 = re.search(test_set_1, d2)
                    m3 = re.search(test_set_2, d2)
                    if m2:
                        src_dir = os.path.abspath(os.path.join(path2, d2))
                        for path3, dirs3, files3 in os.walk(src_dir):
                            for d3 in dirs3:
                                src = os.path.abspath(os.path.join(path3, d3))
                                dst = test_dir + '/' + category + '/' + instance + '/' + d3
                                #print "copy '%s' to '%s'" % (src, dst) 
                                shutil.copytree(src, dst)
                    elif m3:
                        src_dir = os.path.abspath(os.path.join(path2, d2))
                        for path3, dirs3, files3 in os.walk(src_dir):
                            for d3 in dirs3:
                                src = os.path.abspath(os.path.join(path3, d3))
                                dst = test_dir + '/' + category + '/' + instance + '/' + d3
                                #print "copy '%s' to '%s'" % (src, dst) 
                                shutil.copytree(src, dst)
                    else:
                        src_dir = os.path.abspath(os.path.join(path2, d2))
                        for path3, dirs3, files3 in os.walk(src_dir):
                            for d3 in dirs3:
                                src = os.path.abspath(os.path.join(path3, d3))
                                dst = train_dir + '/' + category + '/' + instance + '/' + d3
                                #print "copy '%s' to '%s'" % (src, dst) 
                                shutil.copytree(src, dst)

print 'done'
