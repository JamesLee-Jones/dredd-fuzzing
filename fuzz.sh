#!/bin/bash

CPUS=8
for ((i=1;i<=$CPUS;i++)); do
  ./fuzz-semantics-preserving.sh "random-$i"
done
