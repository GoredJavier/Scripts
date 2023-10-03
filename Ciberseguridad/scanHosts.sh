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
binMask0aux=""
binMask1=""
binMask1aux=""
binMask=""
binMaskaux=""
cidr=$2
mask=$((32 - cidr))
baseIP=""
lastIP=""
rangeIP=""

# FUNCTIONS

function parseIP(){
  for i in $(seq 1 4); do
    aux=$(echo "$1" | cut -d "." -f $i | xargs -I {} echo "obase=2; {}" | bc)
    ip[$i]=$(printf "%08u" "$aux")
  done
  binIP="${ip[1]}${ip[2]}${ip[3]}${ip[4]}"
}

function calculateNextIP(){
  binaryIP=$1
  decimalIPaux=$(echo "ibase=2; $binaryIP" | bc)
  decimalIPaux=$((decimalIPaux + 1))
  binaryIP=$(echo "obase=2; $decimalIPaux" | bc)
  echo "$binaryIP"
}

function calculateDecimalIP(){
  binIP=$1
  octet1Bin=${binIP:0:8}
  octet2Bin=${binIP:8:8}
  octet3Bin=${binIP:16:8}
  octet4Bin=${binIP:24:8}
  octet1=$(echo "ibase=2; $octet1Bin" | bc)
  octet2=$(echo "ibase=2; $octet2Bin" | bc)
  octet3=$(echo "ibase=2; $octet3Bin" | bc)
  octet4=$(echo "ibase=2; $octet4Bin" | bc)
  point="."
  decimalIP="$octet1$point$octet2$point$octet3$point$octet4"
  echo "$decimalIP"
}

function calculateRangeIP(){
  decimalFirst=$(echo "ibase=2; $baseIP" | bc)
  decimalLast=$(echo "ibase=2; $lastIP" | bc)
  rangeIP=$((decimalLast - decimalFirst))
  echo "$rangeIP"
}

function scanHosts(){
  echo "Hola"
  actualIPbin=$baseIP
  for ((i=0; i<rangeIP; ++i));do
    actualIP=$(calculateDecimalIP $actualIPbin)
    echo -e "\n$actualIP"
    actualIPbin=$(calculateNextIP $actualIPbin)
  done
}

function calculateBaseIP(){
  echo -e "\nVamos a calcular la IP base de $binIP con la mask $binMask"
  decimalMask=$(echo "ibase=2; $binMask" | bc)
  decimalIP=$(echo "ibase=2; $binIP" | bc)
  decimalBaseIP=$(((decimalIP & decimalMask) + 1))
  baseIP=$(echo "obase=2; $decimalBaseIP" | bc)
}

function calculateMasks(){
  decimalMask0=$mask
  decimalMask1=$cidr
  zeroBit="0"
  oneBit="1"
  for ((i=0; i<decimalMask0; i++)); do
    binMask0="$binMask0$zeroBit"
    binMask1aux="$binMask1aux$oneBit"
  done
  for ((i=0; i<decimalMask1; i++)); do
    binMask1="$binMask1$oneBit"
    binMask0aux="$binMask0aux$zeroBit"
  done
  binMask="$binMask1$binMask0"
  binMaskaux="$binMask0aux$binMask1aux"
}

function calculateLastIP(){
  echo -e "\nVamos a calcular la ultima IP"
  size=${#baseIP}
  size=$((size-1))
  for ((i=0; i<$size; ++i));do
    if [ "${baseIP:i:1}" == "1" ] || [ "${binMaskaux:i:1}" == "1" ]; then
      lastIP+="1"
    else
      lastIP+="0"
    fi
  done
  lastIP+="0"
  echo "$lastIP"
  decimal=$(calculateDecimalIP $lastIP)
  echo "$decimal"
  next=$(calculateNextIP $lastIP)
  echo "$next"
}

# MAIN

tput civis

if [ $1 ] && [ $2 ]; then
  parseIP $1
  calculateMasks
  calculateBaseIP
  calculateLastIP
  calculateRangeIP
  scanHosts
else
  echo -e "\n\n[!] Indica como primer párametro la IP y segundo el CIDR!\n"
fi
tput cnorm
