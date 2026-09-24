#!/bin/bash 

running=1


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
	echo "$output_file" #delete
	

	if [ ! -s "$input_file" ]; then
		echo "usage: the file is empty - no .bin file is produced"
		exit 1
	else
		echo "we are continuing with code" #delete
	fi	

fi

line1=$(sed -n '1p' "$input_file")

echo "about to check first line"
Line1="${line1%$'\r'}"
#want to first check that they are integers, then if they are 0 or 2
if [ "$Line1" -ne 0 ] && [ "$Line1" -ne 2 ]; then
	echo "I don't know the error message but this is wrong, as the first line is not 0 or 2"

elif [ "$Line1" -eq 0 ]; then
	line2=$(sed -n '2p' "$input_file")
	Line2="${line2%$'\r'}"
	if [ "$Line2" ==  "QUIT,0,0" ]; then
		printf '\x20' > filename.bin
		printf '\x00' >> filename.bin	
		xxd -c 1 filename.bin
#need to add extra dialogue lines here

	fi

elif [ "$Line1" -eq 2 ]; then
	echo "time to go in the 2 branch" #delete
	line2=$(sed -n '2p' "$input_file")
	Line2="${line2%$'\r'}"
	
	if ! [[ "$Line2" =~ ^[0-9]+$ ]]; then
		echo "usage: non-integer in data space"		
		exit 1
	elif (( "$Line2" >= 0 && "$Line2" \< 128)); then
		printf 'number is good\n' 
		line3=$(sed -n '3p' "$input_file")
		Line3="${line3%$'\r'}"
		if ! [[ "$Line3" =~ ^[0-9]+$ ]]; then
			echo "usage: non-integer in data space"
			exit 1
		elif (( "$Line3" >= 0 && "$Line3" \< 128 )); then
			printf 'number is good \n'
			
			dataArray=()
			dataArray[0]="$Line1"
			dataArray[1]="$Line2"
			echo "${dataArray[0]}"
			echo "${dataArray[1]}"			
			echo "data Array echoed"

		else
			
			printf 'Number no good once again'
			exit 1



		fi

	
	else
		printf "NUMBER IS BAD"
		exit 1

	fi




fi


reading_file=0
i=3
line_count=$(wc -l < "$input_file")

echo "about to give line count"
echo "$line_count"

while [ $i -le $line_count ]:
	printf '$i'
	i=$(( $i + 1 ))
	
	




while IFS= read -r line; do
	printf '%s\n' "$line"




done < "$input_file"




