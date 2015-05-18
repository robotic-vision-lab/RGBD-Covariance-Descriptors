#!/usr/bin/env python
#
# Generate a category dataset based on an input dataset minus the object
# instance from a trial file.
#
import re
import os
import sys
import shutil

if len(sys.argv) != 4:
    print "Usage: generate_category_dataset source_dir dest_dir trial_file"
    sys.exit()

src_dir = sys.argv[1]
dst_dir = sys.argv[2]
trial_file = sys.argv[3]

with open(trial_file) as f:
    instances = f.read().splitlines()

# Create the destination directory
print 'Creating destination directory ...', 
shutil.copytree(src_dir, dst_dir)
print 'done'

# Prune the destination directory
print 'Pruning destination directory ...',
for path, dirs, files in os.walk(dst_dir):
    if len(files):
        # Remove instance
        for f in files:
            if os.path.splitext(f)[0] in instances:
                file = os.path.abspath(os.path.join(path, f))
                os.remove(file)
print 'done'

print 'Moving instances into a single file ...',
for path, dirs, files in os.walk(dst_dir):
    if len(files):
        # Move other instances into a single file
        m = re.search('/(\w+)$', path)
        cov_file = os.path.abspath(os.path.join(path, m.group(1) + '.cov'))
        with open(cov_file, 'a') as outfile:
            for f in files:
                file = os.path.abspath(os.path.join(path, f))
                with open(file) as infile:
                    for line in infile:
                        outfile.write(line)
                os.remove(file)
print 'done'
