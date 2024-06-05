#!/bin/bash
set -e

export PATH=$PATH:$HOME/dev/csmith/build/bin
export PATH=$PATH:$HOME/dev/dredd/third_party/clang+llvm/bin

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 filename"
  exit 1
fi

filename=$1

COUNTER=0
while :
do
  echo $COUNTER
  COUNTER=$((COUNTER+1))

  csmith --lang-cpp --cpp11 > "$filename.cc"
  clang++ -fbracket-depth=1024 -fsanitize=undefined -Wno-c++11-narrowing -I$HOME/dev/csmith/build/include -MJ "$filename.cc.json" -w "$filename.cc" -o "$filename"
  sed -e '1s/^/[\'$'\n''/' -e '$s/,$/\'$'\n'']/' *.cc.json > "${filename}_compile_commands.json"


	echo "CHECKING RANDOM TERMINATES"
	timeout 20s "./$filename"
	retVal=$?
	if [ $retVal -eq 124 ]; then
		echo "  DIDN'T TERMINATE"
		continue
	fi

  cp "$filename.cc" "$filename-instrumented.cc"

  dredd -p "${filename}_compile_commands.json" --semantics-preserving-coverage-instrumentation "$filename-instrumented.cc" > /dev/null
  retVal=$?
  if [ $retVal -ne 0 ]; then
    cp "$filename.cc" "dredd-error/$filename-$(date +%s).c"
  fi

  clang++ -fbracket-depth=1024 -fsanitize=undefined -Wno-c++11-narrowing -I$HOME/dev/csmith/build/include -w "$filename-instrumented.cc" -o "$filename-instrumented"
  retVal=$?
  if [ $retVal -ne 0 ]; then
    cp "$filename.cc" "compile-error/$filename-$(date +%s).c"
  fi



	echo "COMPARING OUTPUT"
	timeout 40s diff <("./$filename") <("./$filename-instrumented")
	retVal=$?
  if [ $retVal -eq 124 ]; then
    continue
  elif [ $retVal -ne 0 ]; then
    cp "$filename.cc" "semantics-error/$filename-$(date +%s).c"
		exit 1
  fi

  rm "$filename.cc" "$filename-instrumented.cc" "$filename.cc.json" "${filename}_compile_commands.json"
done

