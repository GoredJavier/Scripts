#!/bin/bash

trap ctrl_C SIGINT

function ctrl_C(){
  tput cnorm
  echo -e "\n\n[+] Saliendo...\n"
  tput civis
  exit 1
}

function checkPort(){
  (exec 3<> /dev/tcp/$1/$2) 2>/dev/null
  if [ $? -eq 0 ]; then
    echo -e "[+] El {Puerto}: $2 del {Host}: $1 está abierto\n"
  fi
  exec 3>&-
  exec 3<&-
}

declare -a ports=( $(seq 1 65535) )

if [ $1 ]; then
  for port in ${ports[@]}; do
    checkPort $1 $port &
  done
fi

wait
