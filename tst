#!/usr/bin/env bash

set -e

usage="$(basename $0)"
syntax="

node -e 'console.log(3)':
# logging "3" should print "3"
3
"
tst_file=.tst

input_comment=""
input_test=""
input_match=""

add_test() {
	input_test="$1"
}
validate_test() {
	if [[ -z "$input_test" ]]; then
		return
	fi
	result="$(eval $input_test)"
	if [[ "$input_match" == "$result" ]]; then
		# test validated
		return
	else
		echo $input_test:
		echo $input_comment
		echo -e "\e[31m$result\e[0m"
		echo -e "\e[32m$input_match\e[0m"
	fi
	clear_test
	clear_comment
	clear_match
}
clear_test() {
	input_test=""
}
add_comment() {
	input_comment="$1"
}
clear_comment() {
	input_comment=""
}
add_match() {
	if [[ -z "$input_match" ]]; then
		input_match="$1"
	else
		input_match+="
$1"
	fi
}
clear_match() {
	input_match=""
}




# $1: .tst file
run_tests() {
	while read -r line; do
		if [[ "${line: -1}" == ":" ]]; then
			validate_test
			# test
			add_test "${line: 0: -1}"
		elif [[ "${line: 0: 2}" == "# " ]]; then
			# comment
			add_comment "${line: 2}"
		else
			# match
			add_match "$line"
		fi
	done <<< "$(cat $tst_file)"
	validate_test
}

if [ "$1" == "help" ]; then
	echo "usage: $usage"
	echo
	echo "Syntax of a .tst file $syntax"
else
	run_tests .tst
fi