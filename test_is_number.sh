#!/bin/bash 

# check if a value is a number (int)

func_test_number() {
	# would also work: if ! [[ $val =~ $re ]]
	# =~ mean match the left side to RE on the right
	re="^[0-9]+$"
	val=$1
	if ! [[ $val =~ ^[0-9]+$ ]]; then
		echo "$val" is not a number
	else
		echo "$val" is a number
	fi
}

func_test_number "some stuff"
func_test_number 329