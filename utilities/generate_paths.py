#!/usr/bin/env python
#
# Generate the absolute paths to files within subdirectories for a given top 
# level directory.
#
import os
import sys

if len(sys.argv) != 2:
    print "Usage: generate_paths path_to_top_level_dir"
    sys.exit()

dir = sys.argv[1]

for path, dirs, files in os.walk(dir):
    for f in files:
        file_path = os.path.abspath(os.path.join(path, f))
        print file_path
