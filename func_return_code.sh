#!/bin/bash

#
# return only allows return code between 0 and 255
# I pretty much acts like exit (result of script or command called by a script)
#

cat << EOF

Returning an error code from a function:
----------------------------------------
Calling exit in a function would cause the whole script to exit.
To return a status from a function just call return [n]

To test:
if ! func
  ... the function has failed

EOF

function fail() {
  echo "I am failing"
  return 1
}

function success() {
  echo "we'll make a success of it. Dixit Theresa May!"
  echo "Implicit return 0"
}


if ! fail ; then
  echo "fail faied"
else
  echo "fail succeeded"
fi

if success ; then
  echo "success succeeded"
else
  echo "success faied"
fi
