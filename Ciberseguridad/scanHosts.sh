#!/bin/bash

#COLOURS

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
yellowColour="\e[0;33m\033[1m"
grayColour="\e[0;37m\033[1m"


# CTRL C EXIT GESTION

trap ctrl_c SIGINT

function ctrl_c(){
  echo -e "\n\n${redColour}[+] Saliendo...${endColour}\n"
  tput cnorm
  exit 1
}

# GLOBAL VARIABLES

declare -a topPorts=("80" "443" "22" "25" "21")
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
  rangeIP=$((decimalLast - decimalFirst + 1))
}

function scanHosts(){
  actualIPbin=$baseIP
  for ((i=0; i<rangeIP; ++i));do
    actualIP=$(calculateDecimalIP $actualIPbin)
    actualIPbin=$(calculateNextIP $actualIPbin)
    for port in "${topPorts[@]}"; do
      timeout 1 bash -c "echo '' > /dev/tcp/$actualIP/$port" 2>/dev/null && echo -e "\n${grayColour}[+] El Host ${yellowColour}${actualIP}${endColour} ${grayColour}está${endColour} ${greenColour}activo${endColour} ${grayColour}y con el puerto${endColour} ${yellowColour}${port}${endColour} ${greenColour}abierto${endColour}${grayColour}.${endColour}" &
    done
  done
  wait
}

function calculateBaseIP(){
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
}

# MAIN

tput civis

if [ $2 -ge 31 ] || [ $2 -le 16 ]; then
  echo -e "\n\n${redColour}[!] CIDR incorrecto o no aceptado!${endColour}\n"
elif [ $1 ] && [ $2 ]; then
  parseIP $1
  calculateMasks
  calculateBaseIP
  calculateLastIP
  calculateRangeIP
  scanHosts
else
  echo -e "\n\n${redColour}[!] Indica como primer párametro la IP y segundo el CIDR!${endColour}\n"
fi
tput cnorm
