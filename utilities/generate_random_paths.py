#!/usr/bin/env python
#
# Generate test and training lists of absolute paths to files within 
# subdirectories for a given top level directory.  Each test path is randomly 
# selected for a given input directory.  The test and training paths are written 
# out to separate files. 
#
import os
import sys
import random

if len(sys.argv) != 2:
    print "Usage: generate_random_paths path_to_top_level_dir"
    sys.exit()

dir = sys.argv[1]
train_paths = open('train_paths.txt', 'w')
test_paths = open('test_paths.txt', 'w')

for path, dirs, files in os.walk(dir):
    file_count = len(files)
    if file_count:
        r = random.randint(1, file_count)
        i = 1;
    for f in files:
        file_path = os.path.abspath(os.path.join(path, f))
        if i == r:
            test_paths.write(file_path + '\n')
        else:
            train_paths.write(file_path + '\n')
        i = i + 1

train_paths.close()
test_paths.close()
