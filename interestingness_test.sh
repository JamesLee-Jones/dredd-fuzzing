#!/bin/bash

set -e

export PATH=$PATH:$HOME/dev/dredd/third_party/clang+llvm/bin

clang random.c -I$HOME/dev/csmith/build/include -MJ random.c.json -o random
sed -e '1s/^/[\'$'\n''/' -e '$s/,$/\'$'\n'']/' *.c.json > compile_commands.json
cp random.c random-dredd.c
dredd -p compile_commands.json random-dredd.c --mutation-info-file temp.json --no-mutation-opts
clang -I$HOME/dev/csmith/build/include random-dredd.c -o random-instrumented |& grep "error: conflicting types"


