#!/bin/bash 

printf "\nUpdating Visual Studio Code from the Downloads folder\n\n"
version=$(find ~/Downloads -name "code_*"  -ls | tail -1 | awk '{f=""; for(i=8; i<=NF; i++) s= s $i" "; print s}')
read -p "Is $version correct? (y/n) " resp
if [[ $resp == "y" || $resp == "Y" ]]; then
  correct_file=$(echo $version | awk '{print $NF}')
  printf "\nUpdating with $correct_file\n\n"
   sudo dpkg -i "$correct_file"
else
  printf "\nPlease update manually. Ex: sudo dpkg -i code_n.nnnn_amd64.deb\n\n"
fi
