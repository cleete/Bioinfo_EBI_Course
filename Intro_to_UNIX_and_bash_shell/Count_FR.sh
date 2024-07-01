#!/bin/bash
pattern=$1
filename=$2
for name in $filename
do
bash count_input.sh $pattern $name
done
