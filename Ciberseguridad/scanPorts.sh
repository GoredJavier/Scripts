#!/bin/bash

# COLORS

endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
grayColour="\e[0;37m\033[1m"
turquoiseColour="\e[0;36m\033[1m"

# CTRL C INTERRUPT GESTION

trap ctrl_C SIGINT

function ctrl_C(){
  tput cnorm
  echo -e "\n\n${redColour}[+] Saliendo...${endColour}\n"
  tput civis
  exit 1
}

# FUNCTIONS

function checkPort(){
  (exec 3<> /dev/tcp/$1/$2) 2>/dev/null
  if [ $? -eq 0 ]; then
    echo -e "${grayColour}[+] El ${endColour}${purpleColour}Puerto${endColour}${grayColour}:${endColour} ${yellowColour}$2${endColour} ${grayColour}del ${endColour}${purpleColour}Host${endColour}${grayColour}:${endColour} ${yellowColour}$1${endColour} ${grayColour}está abierto${endColour}\n"
  fi
  exec 3>&-
  exec 3<&-
}

declare -a ports=( $(seq 1 65535) )

# MAIN SCRIPT

tput civis

if [ $1 ]; then
  echo -e "${turquoiseColour}[i] Iniciando escaneo de puertos...${endColour}\n\n"
  for port in ${ports[@]}; do
    checkPort $1 $port &
  done
else
  echo -e "\n\n${redColour}[!] Indique la IP!${endColour}\n"
fi

wait

tput cnorm
