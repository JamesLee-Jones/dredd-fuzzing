#!/bin/bash

export PATH=$PATH:$HOME/dev/dredd/third_party/clang+llvm/bin

clang random.c -I$HOME/dev/csmith/build/include -MJ random.c.json -o random
sed -e '1s/^/[\'$'\n''/' -e '$s/,$/\'$'\n'']/' *.c.json > compile_commands.json
cp random.c random-dredd.c
dredd -p compile_commands.json random-dredd.c
clang -I$HOME/dev/csmith/build/include random-dredd.c -o random-instrumented
timeout 4m ./random
retVal=$?
if [ $retVal -eq 124 ]; then
	exit 1
fi
timeout 4m diff <(./random) <(./random-instrumented)
retVal=$?
if [ $retVal -eq 124 ]; then
	exit 0
else
	exit 1
fi

