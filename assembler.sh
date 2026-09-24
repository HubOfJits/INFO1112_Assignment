#!/bin/bash 

decimal_to_binary(){
num=$1
binary=""
temp=num

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

		else
			echo not found
			echo "usage: command is invalid"
			exit 1
		fi		
		

	
	fi
	
done
	


#echo "Now comes stuff I've not yet bothered to delete"

#while IFS= read -r line; do
#	printf '%s\n' "$line"




#done < "$input_file"
