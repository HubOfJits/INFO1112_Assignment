#!/bin/bash 

decimal_to_binary(){
num=$1
binary=""
temp=$num

for weight in 128 64 32 16 8 4 2 1
do
if (( $temp >= $weight )); then

binary="${binary}1"
temp=$(( $temp - $weight ))

else
binary="${binary}0"

fi

done

echo "$binary"
}

decimal_to_hex(){
num=$1
hex=""
temp=$num

if (( $temp >= 16 )); then
	digit=$(( $temp / 16 ))	

	differand=$(( $digit * 16 ))

	temp=$(( $temp - $differand ))
        if (( $digit == 15 )); then
                hex="${hex}f"

        elif (( $digit == 14 )); then
                hex="${hex}e"

        elif (( $digit == 13 )); then
                hex="${hex}d"

        elif (( $digit == 12 )); then
                hex="${hex}c"

        elif (( $digit == 11 )); then
                hex="${hex}b"

        elif (( $digit == 10 )); then
                hex="${hex}a"

        else
                hex="${hex}$digit"
	fi
else
	hex="${hex}0"
fi


if (( $temp >= 1 )); then

	if (( $temp == 15 )); then
		hex="${hex}f"

        elif (( $temp == 14 )); then
                hex="${hex}e"
	
        elif (( $temp == 13 )); then
                hex="${hex}d"

        elif (( $temp == 12 )); then
                hex="${hex}c"

        elif (( $temp == 11 )); then
                hex="${hex}b"

        elif (( $temp == 10 )); then
                hex="${hex}a"

        else
                hex="${hex}$temp" 
	fi	

else
	hex="${hex}0"

fi



echo "$hex"
}


if [ "$#" -eq 0 ]; then
	echo "usage: no argument is provided"
	exit 1
fi

if ! [ -z "$2" ]; then
	echo "usage: more than one arguments are provided"
	exit 1
fi


if ! [ -f "$1" ]; then
	echo "usage: input is not a file or it does not exist"
	exit 1
fi


if ! [[ "$1" =~ \.vsc$ ]]; then
	echo "usage: input does not have the extension .vsc"
	exit 1
else
	input_file="$1"
	output_file="${input_file%.vsc}.bin"
	#echo "$output_file" #delete
	

	if [ ! -s "$input_file" ]; then
		echo "usage: the file is empty - no .bin file is produced"
		exit 1
		#echo "we are continuing with code" #delete
	fi	

fi

line1=$(sed -n '1p' "$input_file")

#echo "about to check first line"
Line1="${line1%$'\r'}"
#want to first check that they are integers, then if they are 0 or 2
if [ "$Line1" -ne 0 ] && [ "$Line1" -ne 2 ]; then
	echo "Invalid first line"
	exit 1
elif [ "$Line1" -eq 0 ]; then
	line2=$(sed -n '2p' "$input_file")
	Line2="${line2%$'\r'}"
	if [ "$Line2" == "QUIT,0,0" ]; then
		printf '\x20' > filename.bin
		printf '\x00' >> filename.bin	
		xxd -c 1 filename.bin
	#need to add extra dialogue lines here

	fi

elif [ "$Line1" -eq 2 ]; then
	#echo "time to go in the 2 branch" #delete
	line2=$(sed -n '2p' "$input_file")
	Line2="${line2%$'\r'}"
	
	if ! [[ "$Line2" =~ ^[0-9]+$ ]]; then
		echo "usage: non-integer in data space"		
		exit 1
	elif (( "$Line2" >= 0 && "$Line2" \< 128)); then
		#printf 'number is good\n' 
		line3=$(sed -n '3p' "$input_file")
		Line3="${line3%$'\r'}"
		if ! [[ "$Line3" =~ ^[0-9]+$ ]]; then
			echo "usage: non-integer in data space"
			exit 1
		elif (( "$Line3" >= 0 && "$Line3" \< 128 )); then
			#printf 'number is good \n'
			
			dataArray=()
			dataArray[0]="$Line1"
			dataArray[1]="$Line2"
			dataArray[2]="$Line3"		
			#echo "${dataArray[0]}"
			#echo "${dataArray[1]}"			
			#echo "data Array echoed"

		else
			
			#printf 'Number no good once again'
			exit 1

		fi
	else
		#printf "NUMBER IS BAD"
		exit 1

	fi


fi


number_of_lines=$(wc -l < "$input_file")
number_of_lines="$(echo -e "${number_of_lines}" | tr -d '[:space:]')"
echo "$number_of_lines"

for (( i = 4; i <= "$number_of_lines"; i++ ))
do
	echo "I am running a loop now"
	line=$(sed -n "${i}p" "$input_file")
	

	line_count=$(echo "$line" | tr -d '\n' |  wc -c)
	
	if (( "$line_count" > 11 )); then

		echo "usage: unknown command in line"
		exit 1
	else
		IFS=, read -r ins reg mem <<< "$line"
		echo "$ins"
		echo "$reg"
		echo "$mem"
		
		if grep -q "$ins" command_list.txt; then
			echo found
			if [ "$ins" == "LOAD" ]; then
				opcode=000001
			elif [ "$ins" == "STORE" ]; then
				opcode=000010
			elif [ "$ins" == "ADD" ]; then
				opcode=000011
			elif [ "$ins" == "SUB" ]; then
				opcode=000100
			elif [ "$ins" == "QUIT" ]; then
				opcode=001000
			elif [ "$ins" == "PRINT" ]; then
				opcode=001001
			fi

			echo "$opcode"

		else
			echo not found
			echo "usage: command is invalid"
			exit 1
		fi		

	        if ! [[ "$reg" =~ ^[0-9]+$ ]]; then
                	#consider when reg is empty
			echo "usage: non-integer in register space"
        	        exit 1
	        elif (( "$reg" >= 0 && "$reg" \< 4)); then
			if (( "$reg" == 0 )); then
				regbin=00
			elif (( "$reg" == 1 )); then
				regbin=01
			elif (( "$reg" == 2 )); then
				regbin=10
			elif (( "$reg" == 3 )); then
				regbin=11
			fi
			echo "$regbin"
		else
			echo "usage: register value inavlid"
			exit 1
		fi                
		byte1=$opcode$regbin
		echo "$byte1"
		j=$(( $i - 1 ))
		dataArray[j]=$(decimal_to_hex $((2#$byte1)))
		echo "echoing data Array"
		echo "${dataArray[j]}"
 		if ! [[ "$mem" =~ ^[0-9]+$ ]]; then
			#consider when reg is empty
			echo "usage: non-integer in register space"
			exit 1

		elif (( "$mem" >= 0 && "$mem" \< 256 )); then
			decimal_to_binary "$mem"
			#binary call here
			echo "mem good"
		else
			echo "usage: memory value invalid"
			exit 1

		fi



	fi
	
done
	

array_length=${#dataArray[@]}
echo "$array_length"
for (( i = 0; i < $array_length; i++ ))
do
	echo "${dataArray[i]}"
done
