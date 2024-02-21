#!/bin/bash

export PATH=$PATH:$HOME/dev/csmith/build/bin
export PATH=$PATH:$HOME/dev/dredd/third_party/clang+llvm/bin

COUNTER=0
while :
do
	echo $COUNTER
	csmith > random.c

	clang random.c -I$HOME/dev/csmith/build/include -MJ random.c.json
	sed -e '1s/^/[\'$'\n''/' -e '$s/,$/\'$'\n'']/' *.c.json > compile_commands.json
	cp random.c random-dredd.c

	dredd -p compile_commands.json random-dredd.c
	retVal=$?
	if [ $retVal -ne 0 ]; then
		cp random.c "dredd-error/random-$(date +%s).c"
	fi

	clang -I$HOME/dev/csmith/build/include random-dredd.c
	retVal=$?
	if [ $retVal -ne 0 ]; then
		cp random.c "compile-error/random-$(date +%s).c"
	fi

	rm random.c random-dredd.c random.c.json compile_commands.json
	COUNTER=$((COUNTER+1))
done

