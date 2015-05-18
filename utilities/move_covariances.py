#!/usr/bin/env python
#
# Move covariance files generated from a set of categories to a destination 
# directory.
#
import re
import os
import sys
import glob
import shutil

categories = ['apple', 'ball', 'banana', 'bell_pepper', 'binder', 'bowl', \
              'calculator', 'camera', 'cap', 'cell_phone', 'cereal_box', \
              'coffee_mug', 'comb', 'dry_battery', 'flashlight', 'food_bag', \
              'food_box', 'food_can', 'food_cup', 'food_jar', 'garlic', \
              'glue_stick', 'greens', 'hand_towel', 'instant_noodles', \
              'keyboard', 'kleenex', 'lemon', 'lightbulb', 'lime', 'marker', \
              'mushroom', 'notebook', 'onion', 'orange', 'peach', 'pear', \
              'pitcher', 'plate', 'pliers', 'potato', 'rubber_eraser', \
              'scissors', 'shampoo', 'soda_can', 'sponge', 'stapler', \
              'tomato', 'toothbrush', 'toothpaste', 'water_bottle']

if len(sys.argv) != 2:
    print "Usage: move_covariances dest_dir"
    sys.exit()

dst_dir = sys.argv[1]

# Create the destination directory
if not os.path.exists(dst_dir):
    print 'Creating destination directory ...',
    os.makedirs(dst_dir)
    for c in categories:
        cov_dir = dst_dir + '/' + c
        os.makedirs(cov_dir)
    print 'done'

# Move covariance files to the destination directory
print 'Moving covariances to destination directory ...',
for f in glob.glob('*.cov'):
    m = re.search('(.*)_\d+', f)
    if m:
        file = os.path.abspath(f)
        dst = os.path.abspath(dst_dir) + '/' + m.group(1)
        shutil.move(file, dst)
print 'done'
