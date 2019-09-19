#!/bin/bash 

# Demo returning local variable
g_var=5555555

func() {
	g_var="10"
	# use  echo "not part of the rurn" >&2 in order not to capture the looging message in the result functio
	echo "setting local var to 3" >&2
	local l_var=3
	echo "setting global var to 10" >&2

	echo "global var in func="$g_var >&2
	# return l_var using echo
	echo $l_var
}

func2() {
	local l=333
	g_var=1000
	echo "stuff in func2" >&2
}

# evaluate the function () equivalent to ``
# evaluating a function seems to hide the global variables
res=$(func)
echo "Return from function = "$res
echo "global variable g_var = "$g_var
func2
echo "After calling func2 global variable g_var = "$g_var
