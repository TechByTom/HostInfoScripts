#!/bin/bash
if [ $# -ne 2 ]; then
	# Print usage since this isn't how to use the tool.
	echo "Execute this tool to iterate through each line of a file and run the same command on each line"
	echo "Usage: Foreach <tool> <filename>"
	echo
	exit 1
fi
while read line; do
	$1 $line
done <$2
