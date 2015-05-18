#!/bin/sh

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/

module load matlab

matlab -nodesktop -nodisplay $* -r "addpath('dictionary_learning', 'covariance_descriptor', 'utilities', 'matpcl', 'estimate_normal', 'estimate_curvatures', 'spams/build', 'spams/test_release'); setenv('MKL_NUM_THREADS','1'); setenv('MKL_SERIAL','YES'); setenv('MKL_DYNAMIC','NO');"
