#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_C(){
    if [ -z "$algoritmo" ]; then
      echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
      exit 1
    fi
    echo -e "\n\n${purpleColour}+${endColour}${yellowColour}------------------------------${endColour}${purpleColour}+${endColour}"
    echo -e "${yellowColour}+${endColour} ${blueColour}MENÚ DEL SIMULADOR DE RULETA${endColour} ${yellowColour}+${endColour}"
    echo -e "${purpleColour}+${endColour}${yellowColour}------------------------------${endColour}${purpleColour}+${endColour}"
    echo -e "\n\n${grayColour}Pulse${endColour} ${purpleColour}1${endColour} ${grayColour}para cambiar su${endColour} ${purpleColour}apuesta${endColour}${grayColour}.${endColour}\n${grayColour}Pulse${endColour} ${purpleColour}2${endColour} ${grayColour}para parar el${endColour} ${purpleColour}juego${grayColour}.${endColour}${endColour}\n${grayColour}Pulse${endColour} ${purpleColour}3${endColour} ${grayColour}para cambiar${endColour} ${purpleColour}cantidad${endColour}${grayColour}.${endColour}\n${grayColour}Pulse${endColour} ${purpleColour}4${endColour} ${grayColour}para${endColour} ${purpleColour}continuar${endColour}${grayColour}.${endColour}\n${grayColour}Pulse${endColour} ${purpleColour}5${endColour} ${grayColour}para obtener las${endColour} ${purpleColour}estadísticas${endColour} ${grayColour}actuales.${endColour}" && read option
    if [ "$option" == "1" ]; then
      if [ "$bet" == "par" ]; then
        bet="impar"
        echo -e "\n${yellowColour}[+]${endColour} ${blueColour}Apuesta cambiada a ${endColour}${yellowColour}$bet${endColour}${blueColour}.${endColour}\n\n"
        sleep 2
      else 
        bet="par"
        echo -e "\n${yellowColour}[+]${endColour} ${blueColour}Apuesta cambiada a ${endColour}${yellowColour}$bet${endColour}${blueColour}.${endColour}\n\n"
        sleep 2
      if [ "$algoritmo" == "martingala" ]; then
        playMartingala 1
      elif [ "$algoritmo" == "inverseLabouchere" ]; then
        playLabouchere 1
      fi
      fi
    elif [ "$option" == "2" ]; then
      echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
      exit 1
    elif [ "$option" == "3" ]; then
      if [ "$algoritmo" == "martingala" ]; then
        echo -ne "\n${blueColour}Escriba la${endColour} ${yellowColour}apuesta${endColour} ${blueColour}deseada a partir de ahora:${endColour} " && read apuesta
        actual_bet=$apuesta
        echo -e "\n${yellowColour}[+]${endColour} ${blueColour}Apuesta cambiada${endColour} ${yellowColour}$actual_bet${endColour} ${blueColour}euros.${endColour}\n\n"
        sleep 2
        playMartingala 2
      elif [ "$algoritmo" == "inverseLabouchere" ]; then
        echo -ne "\n${blueColour}Escriba la secuencia de${endColour} ${yellowColour}apuestas${endColour} ${blueColour}deseada a partir de ahora:${endColour} " && read -a apuesta
        bet_array=("${apuesta[@]}")
        echo -ne "\n${yellowColour}[+]${endColour} ${blueColour}Serie de apuestas cambiada a: ${endColour}"
        size=${#bet_array[@]}
        for element in "${bet_array[@]}"; do
          if [ $element -eq ${bet_array[$((size - 1))]} ]; then
            echo -ne "${yellowColour}$element${endColour}\n\n"
          else
          echo -ne "${yellowColour}$element${endColour}${purpleColour},${endColour} "
          fi
        done
        sleep 2
        playLabouchere 2
      fi
    elif [ "$option" == "4" ]; then
      if [ "$algoritmo" == "martingala" ]; then
        playMartingala 1
      elif [ "$algoritmo" == "inverseLabouchere" ]; then
        playLabouchere 1
      fi
    elif [ "$option" == "5" ]; then
      echo -e "\n\n${blueColour}->${endColour} ${yellowColour}ESTADÍSTICAS DE LA SESIÓN${endColour} ${blueColour}<-${endColour}\n"
      echo -e "\n${yellowColour}-${endColour} ${blueColour}La racha máxima de pérdidas ha sido:${endColour} ${yellowColour}$max_loose_chain${endColour}${blueColour}.${endColour}\n"
      echo -e "${yellowColour}-${endColour} ${blueColour}El máx win de la sesión ha sido:${endColour} ${yellowColour}$max_win${endColour}${blueColour}.${endColour}\n"
      echo -e "${yellowColour}-${endColour} ${blueColour}La cantidad máxima de dinero alcanzada ha sido:${endColour} ${yellowColour}$max_money${endColour}${blueColour}.${endColour}\n"
    else
      echo -e "\n\n${redColour}[!] Opción introduzida errónea, vuelva a probar..!${endColour}\n"
    fi
}

trap ctrl_C INT

function helpPanel(){  
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Uso del script ${endColour}${purpleColour}$0${endColour}${grayColour}:${endColour} "
  echo -e "\n${purpleColour}m)${endColour} ${blueColour}Dinero total para jugar.${endColour}"
  echo -e "\n${purpleColour}t)${endColour} ${blueColour}Tipo de algoritmo a aplicar (${grayColour}martingala${endColour} ${blueColour}/${endColour} ${grayColour}inverseLabouchere${endColour}${grayColour}).${endColour}\n"
}

function playMartingala(){
  stopped=$1
  algoritmo="martingala"
  if [ $stopped -eq 0 ]; then
    echo -e "\n${blueColour}Vamos a jugar a la${endColour} ${purpleColour}Martingala!${endColour}"
    echo -ne "\n${grayColour}Inserta la cifra de tu apuesta inicial: ${endColour}" && read actual_bet
    echo -ne "${grayColour}Inserta tu apuesta (par/impar): ${endColour}" && read bet
    echo -e "\n${grayColour}Tenemos apuesta inicial de${endColour} ${yellowColour}$actual_bet${endColour} ${grayColour}euros a${endColour} ${purpleColour}$algoritmo${endColour}${grayColour}.${endColour}"
    if [ $stopped -eq 2 ]; then 
      backup_bet=$actual_bet
    fi
    backup_bet=$actual_bet
    loose_chain=0
    max_loose_chain=0
    spin=0
    max_win=0
    max_money=0
  fi
  while true; do
    tput civis
  	random_num=$(($RANDOM % 37))
    spin=$((spin + 1))
    if [ $money -ge $max_money ]; then
      max_money=$money
    fi
	money=$((money - actual_bet))
    if [ $money -le 0 ]; then
      echo -e "\n${redColour}[!] Te has quedado a 0..!!${endColour}\n"
      echo -e "$max_loose_chain\n"
      tput cnorm
      exit 0
    fi
	echo -e  "${grayColour}--------------------------------------------${endColour}"
    echo -e "${purpleColour}Apostando ${endColour}${yellowColour}$actual_bet${endColour} ${purpleColour}euros...${endColour}"
	if [ "$bet" == "par" ]; then
      if [ $(($random_num % 2)) -eq 0 ]; then
  	    if [ $random_num -eq 0 ]; then
          echo -e "\n${redColour}Ha tocado el 0, has perdido...${endColour}"
          actual_bet=$((2*actual_bet))
          loose_chain=$((loose_chain + 1))
          if [ $loose_chain -gt $max_loose_chain ]; then
            max_loose_chain=$loose_chain
          fi
          echo -e "${yellowColour}[+]${endColour} ${blueColour}Después de esta tirada tienes${endColour} ${yellowColour}$money${endColour} ${blueColour}euros.${endColour}"
	      echo -e  "${grayColour}--------------------------------------------${endColour}"
 		fi
	    echo -e "\nHa tocado par has ganado!"
        money=$((money + 2*actual_bet))
        actual_bet=$backup_bet
        loose_chain=0
        echo -e "${yellowColour}[+]${endColour} ${blueColour}Después de esta tirada tienes${endColour} ${yellowColour}$money${endColour} ${blueColour}euros.${endColour}"
	    echo -e  "${grayColour}--------------------------------------------${endColour}"
      else 
		echo -e "\n${redColour}Ha tocado impar, has perdido...${endColour}"
        actual_bet=$((2*actual_bet))
        loose_chain=$((loose_chain + 1))
        if [ $loose_chain -gt $max_loose_chain ]; then
          max_loose_chain=$loose_chain
        fi
        echo -e "${yellowColour}[+]${endColour} ${blueColour}Después de esta tirada tienes${endColour} ${yellowColour}$money${endColour} ${blueColour}euros.${endColour}"
	    echo -e  "${grayColour}--------------------------------------------${endColour}"
      fi
      sleep 1
  fi
  if [ "$bet" == "impar" ]; then
    if [ $(($random_num % 2)) -eq 0 ]; then
  	    if [ $random_num -eq 0 ]; then
          echo -e "\n${redColour}Ha tocado el 0, has perdido...${endColour}"
          actual_bet=$((2*actual_bet))
          echo -e "${yellowColour}[+]${endColour} ${blueColour}Después del resultado de esta tirada tienes:${endColour} ${yellowColour}$money${endColour} ${blueColour}euros.${endColour}"
	      echo -e  "${grayColour}--------------------------------------------${endColour}"
 		fi
	    echo -e "\n${redColour}Ha tocado par, has perdido...${endColour}"
        actual_bet=$((2*actual_bet))
        echo -e "${yellowColour}[+]${endColour} ${blueColour}Después del resultado de esta tirada tienes:${endColour} ${yellowColour}$money${endColour} ${blueColour}euros.${endColour}"
	    echo -e  "${grayColour}--------------------------------------------${endColour}"
      else 
		echo -e "\nHa tocado impar has ganado!!"
        win=$((2 * actual_bet))
        money=$((money + win))
        if [ $win -ge $max_win ]; then
          max_win=$win
        fi
        actual_bet=$backup_bet
        echo -e "${yellowColour}[+]${endColour} ${blueColour}Después de esta tirada tienes${endColour} ${yellowColour}$money${endColour} ${blueColour}euros.${endColour}"
	    echo -e  "${grayColour}--------------------------------------------${endColour}"
      fi
      sleep 1
  fi
  done
  echo -e "\n\n${blueColour}->${endColour} ${yellowColour}ESTADÍSTICAS DE LA SESIÓN${endColour} ${blueColour}<-${endColour}\n"
  echo -e "\n${yellowColour}-${endColour} ${blueColour}La racha máxima de pérdidas ha sido:${endColour} ${yellowColour}$max_loose_chain${endColour}${blueColour}.${endColour}\n"
  echo -e "${yellowColour}-${endColour} ${blueColour}El máx win de la sesión ha sido:${endColour} ${yellowColour}$max_win${endColour}${blueColour}.${endColour}\n"
  echo -e "${yellowColour}-${endColour} ${blueColour}La cantidad máxima de dinero alcanzada ha sido:${endColour} ${yellowColour}$max_money${endColour}${blueColour}.${endColour}\n"
  tput cnorm
}

function playLabouchere(){
  stopped=$1
  algoritmo="inverseLabouchere"
  if [ $stopped -eq 0 ]; then
    echo -e "\n${blueColour}Vamos a jugar a la${endColour} ${purpleColour}inverse Labouchere!${endColour}"
    echo -ne "\n${grayColour}Inserta la serie de tus apuestas iniciales: ${endColour}" && read -a bet_array
    echo -ne "${grayColour}Inserta tu apuesta (par/impar): ${endColour}" && read bet
    echo -ne "\n${grayColour}Tenemos una serie de apuestas inicial de: ${endColour}"
    size=${#bet_array[@]}
    for element in "${bet_array[@]}"; do
      if [ $element -eq ${bet_array[$((size - 1))]} ]; then
        echo -ne "${yellowColour}$element${endColour}\n\n"
      else
        echo -ne "${yellowColour}$element${endColour}${purpleColour},${endColour} "
      fi
    done
    loose_chain=0
    max_loose_chain=0
    spin=0
    max_win=0
    max_money=0
  fi
  while true; do
    tput civis
    size=${#bet_array[@]}
    random_num=$(($RANDOM % 37))
    spin=$((spin + 1))
    if [ $money -ge $max_money ]; then
      max_money=$money
    fi
      if [ $money -le 0 ]; then
      echo -e "\n\n${redColour}[!] Te has quedado a 0..!!${endColour}\n"
      echo -e "$max_loose_chain\n"
      tput cnorm
      exit 0
    fi
    if [ $size -le 1 ]; then
      echo -e "\n\n${redColour}[!] Te has quedado sin numeros en la serie..!!${endColour}\n"
      tput cnorm
      exit 0
    fi
    for element in "${bet_array[@]}"; do
      if [ $element -eq ${bet_array[$((size - 1))]} ]; then
        echo -ne "${yellowColour}$element${endColour}\n\n"
      else
        echo -ne "${yellowColour}$element${endColour}${purpleColour},${endColour} "
      fi
    done
    actual_bet=$(("${bet_array[0]}" + "${bet_array[$((size - 1))]}"))
	money=$((money - actual_bet))
	echo -e  "${grayColour}--------------------------------------------${endColour}"
    echo -e "${purpleColour}Apostando ${endColour}${yellowColour}$actual_bet${endColour} ${purpleColour}euros...${endColour}"
	if [ "$bet" == "par" ]; then
      if [ $(($random_num % 2)) -eq 0 ]; then
  	    if [ $random_num -eq 0 ]; then
          echo -e "\n${redColour}Ha tocado el 0, has perdido...${endColour}"
          if [ $size -ge 2 ]; then
            unset bet_array[$((size-1))]
            unset bet_array[0]
          fi
          loose_chain=$((loose_chain + 1))
          if [ $loose_chain -gt $max_loose_chain ]; then
            max_loose_chain=$loose_chain
          fi
          echo -e "${yellowColour}[+]${endColour} ${blueColour}Después de esta tirada tienes${endColour} ${yellowColour}$money${endColour} ${blueColour}euros.${endColour}"
	      echo -e  "${grayColour}--------------------------------------------${endColour}"
 		fi
	    echo -e "\nHa tocado par has ganado!"
        win=$((2*actual_bet))
        money=$((money + win))
        if [ $win -ge $max_win ]; then
          max_win=$win
        fi
        bet_array=("${bet_array[@]}" "$actual_bet")
        loose_chain=0
        echo -e "${yellowColour}[+]${endColour} ${blueColour}Después de esta tirada tienes${endColour} ${yellowColour}$money${endColour} ${blueColour}euros.${endColour}"
	    echo -e  "${grayColour}--------------------------------------------${endColour}"
      else 
		echo -e "\n${redColour}Ha tocado impar, has perdido...${endColour}"
        if [ $size -ge 2 ]; then
          unset bet_array[$((size-1))]
          unset bet_array[0]
        fi
        loose_chain=$((loose_chain + 1))
        if [ $loose_chain -gt $max_loose_chain ]; then
          max_loose_chain=$loose_chain
        fi
        echo -e "${yellowColour}[+]${endColour} ${blueColour}Después de esta tirada tienes${endColour} ${yellowColour}$money${endColour} ${blueColour}euros.${endColour}"
	    echo -e  "${grayColour}--------------------------------------------${endColour}"
      fi
      sleep 1
  fi
  if [ "$bet" == "impar" ]; then
    if [ $(($random_num % 2)) -eq 0 ]; then
  	    if [ $random_num -eq 0 ]; then
          echo -e "\n${redColour}Ha tocado el 0, has perdido...${endColour}"
          if [ $size -ge 2 ]; then
            unset bet_array[$((size-1))]
            unset bet_array[0]
          fi
          echo -e "${yellowColour}[+]${endColour} ${blueColour}Después del resultado de esta tirada tienes:${endColour} ${yellowColour}$money${endColour} ${blueColour}euros.${endColour}"
	      echo -e  "${grayColour}--------------------------------------------${endColour}"
 		fi
	    echo -e "\n${redColour}Ha tocado par, has perdido...${endColour}"
          if [ $size -ge 2 ]; then
            unset bet_array[$((size-1))]
            unset bet_array[0]
          fi
        echo -e "${yellowColour}[+]${endColour} ${blueColour}Después del resultado de esta tirada tienes:${endColour} ${yellowColour}$money${endColour} ${blueColour}euros.${endColour}"
	    echo -e  "${grayColour}--------------------------------------------${endColour}"
      else 
		echo -e "\nHa tocado impar has ganado!!"
        win=$((2 * actual_bet))
        money=$((money + win))
        if [ $win -ge $max_win ]; then
          max_win=$win
        fi
        bet_array=("${bet_array[@]}" "$actual_bet")
        echo -e "${yellowColour}[+]${endColour} ${blueColour}Después de esta tirada tienes${endColour} ${yellowColour}$money${endColour} ${blueColour}euros.${endColour}"
	    echo -e  "${grayColour}--------------------------------------------${endColour}"
      fi
      sleep 1
  fi
  done
  echo -e "\n\n${blueColour}->${endColour} ${yellowColour}ESTADÍSTICAS DE LA SESIÓN${endColour} ${blueColour}<-${endColour}\n"
  echo -e "\n${yellowColour}-${endColour} ${blueColour}La racha máxima de pérdidas ha sido:${endColour} ${yellowColour}$max_loose_chain${endColour}${blueColour}.${endColour}\n"
  echo -e "${yellowColour}-${endColour} ${blueColour}El máx win de la sesión ha sido:${endColour} ${yellowColour}$max_win${endColour}${blueColour}.${endColour}\n"
  echo -e "${yellowColour}-${endColour} ${blueColour}La cantidad máxima de dinero alcanzada ha sido:${endColour} ${yellowColour}$max_money${endColour}${blueColour}.${endColour}\n"
  tput cnorm

}

function aux(){
echo "$backup_bet"
}

while getopts "m:t:h" arg; do 
	case $arg in
		m)money="$OPTARG";;
		t)tipo="$OPTARG";;
		h)helpPanel;;
	esac
done

if [ $money ] && [ "$tipo" ]; then
	echo -e "Tenemos $money euros para jugar a $tipo."
    if [ "$tipo" == "martingala" ]; then
      playMartingala 0
    elif [ "$tipo" == "inverseLabouchere" ]; then
      playLabouchere 0
    else
      echo -e "\nTipo de juego no disponible o valido."
    fi
elif [ $money ]; then
    echo -e "\nSe te olvidó indicar el tipo."
elif [ "$tipo" ]; then
    echo -e "\nSe te olvidó meter dinero tontinto!"
else
    helpPanel
fi


