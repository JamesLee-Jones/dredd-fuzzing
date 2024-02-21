#!/bin/bash

export PATH=$PATH:$HOME/dev/csmith/build/bin
export PATH=$PATH:$HOME/dev/dredd/third_party/clang+llvm/bin

COUNTER=0
while :
do
        echo $COUNTER

        csmith > random.c
        clang random.c -I$HOME/dev/csmith/build/include -w -MJ random.c.json -o random
        sed -e '1s/^/[\'$'\n''/' -e '$s/,$/\'$'\n'']/' *.c.json > compile_commands.json

	echo "CHECKING RANDOM TERMINATES"
	timeout 20s ./random
	retVal=$?
	if [ $retVal -eq 124 ]; then
		echo "  DIDN'T TERMINATE"
		continue
	fi

        cp random.c random-dredd.c

        dredd -p compile_commands.json --semantics-preserving-coverage-instrumentation --no-mutation-opts random-dredd.c > /dev/null
        retVal=$?
        if [ $retVal -ne 0 ]; then
                cp random.c "dredd-error/random-$(date +%s).c"
        fi

        clang -I$HOME/dev/csmith/build/include -w random-dredd.c -o random-instrumented
        retVal=$?
        if [ $retVal -ne 0 ]; then
                cp random.c "compile-error/random-$(date +%s).c"
        fi



	echo "COMPARING OUTPUT"
	timeout 40s diff <(./random) <(./random-instrumented)
	retVal=$?
        if [ $retVal -ne 0 ]; then
                cp random.c "semantics-error/random-$(date +%s).c"
		exit 1
        fi

        rm random.c random-dredd.c random.c.json compile_commands.json
        COUNTER=$((COUNTER+1))
done

