#!/bin/bash

python3 parse_log.py $1 $3
python3 phases.py $(dirname $1)/$(basename $1 .txt).processed.txt $2
