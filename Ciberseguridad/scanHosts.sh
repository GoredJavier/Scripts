#!/bin/bash

# CTRL C EXIT GESTION

trap ctrl_c SIGINT

function ctrl_c(){
  echo -e "\n\n[+] Saliendo...\n"
  tput cnorm
  exit 1
}

# GLOBAL VARIABLES

declare -a ip
declare -g binIP
binMask0=""
binMask1=""
binMask=""

# FUNCTIONS

function parseIP(){
  for i in $(seq 1 4); do
    aux=$(echo "$1" | cut -d "." -f $i | xargs -I {} echo "obase=2; {}" | bc)
    ip[$i]=$(printf "%08u" "$aux")
  done
  binIP="${ip[1]}${ip[2]}${ip[3]}${ip[4]}"
}

function calculateBaseIP(){
  echo -e "\nVamos a calcular la IP base de $1 con la mask $binMask"
}

function calculateMask(){
  decimalMask0=$1
  decimalMask1=$2
  zeroBit="0"
  oneBit="1"
  for ((i=0; i<decimalMask0; i++)); do
    binMask0="$binMask0$zeroBit"
  done
  for ((i=0; i<decimalMask1; i++)); do
    binMask1="$binMask1$oneBit"
  done
  binMask="$binMask1$binMask0"
}

# MAIN

tput civis

parseIP $1

cidr=$2
mask=$((32 - cidr))

calculateMask $mask $cidr

calculateBaseIP $binIP

tput cnorm
