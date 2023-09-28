#!/bin/bash

trap ctrl_c SIGINT

function ctrl_c(){
  echo -e "\n\n[+] Saliendo...\n"
  tput cnorm
  exit 1
}

declare -a ip
declare -g binIP

function parseIP(){
  for i in $(seq 1 4); do
    aux=$(echo "$1" | cut -d "." -f $i | xargs -I {} echo "obase=2; {}" | bc)
    ip[$i]=$(printf "%08u" "$aux")
  done
  binIP="${ip[1]}${ip[2]}${ip[3]}${ip[4]}"
}

parseIP $1

echo "$binIP"
