###################################################################################################################################################################
declare -a WILD_STRINGS
declare -a Temporary_Domains_crt
declare -a Level_Domains_crt
declare -a Temporary_Domains_find
declare -a Level_Domains_find
declare -a Temporary_Domains_sub
declare -a Level_Domains_sub
declare -a Temporary_Domains_buffer
declare -a Level_Domains_buffer

file_organize()
{	
	cat ./"$source"/"$source"_crt.txt 2>/dev/null | sort -u >>  ./"$source"/"$source"_crt_final.txt
	cat ./"$source"/"$source"_findomain.txt 2>/dev/null | sort -u >> ./"$source"/"$source"_findomain_final.txt
	cat ./"$source"/"$source"_subfinder.txt 2>/dev/null | sort -u >>  ./"$source"/"$source"_subfinder_final.txt
	cat ./"$source"/"$source"_buffer.txt 2>/dev/null | sort -u >>  ./"$source"/"$source"_buffer_final.txt
	cat ./"$source"/"$source"_crt_final.txt ./"$source"/"$source"_findomain_final.txt ./"$source"/"$source"_subfinder_final.txt ./"$source"/"$source"_buffer_final.txt  > ./"$source"/"$source".txt
	cat ./"$source"/"$source".txt | sort -u >> ./"$source"/"$source"_final.txt
	rm ./"$source"/"$source"_crt.txt ./"$source"/"$source"_findomain.txt ./"$source"/"$source"_subfinder.txt ./"$source"/"$source"_buffer.txt   ./"$source"/"$source".txt 2>/dev/null
}
Level_Unique_crt()
{
	for i in ${Temporary_Domains_crt[@]} ; 
	do
       		if [ $i == $1 ] ; then
        	    echo "1"
        	fi
       done		
}
Level_Unique_sub()
{
	for i in ${Temporary_Domains_sub[@]} ; 
	do
       		if [ $i == $1 ] ; then
        	    echo "1"
        	fi
       done		
}
Level_Unique_find()
{
	for i in ${Temporary_Domains_find[@]} ; 
	do
       		if [ $i == $1 ] ; then
        	    echo "1"
        	fi
       done		
}

Level_Unique_buffer()
{
	for i in ${Temporary_Domains_buffer[@]} ; 
	do
       		if [ $i == $1 ] ; then
        	    echo "1"
        	fi
       done		
}


Help()
{
   # Display Help
   echo "Syntax: USE ARGS [-d|-h|-s|-v]"
   echo "options:"
   echo "d:--> Specify Sub-Domain Depth."
   echo "h:--> Print this Help."
   echo "s:--> Specify Root Domain."
}

while getopts d:s:hv flag
	do
	    case "${flag}" in
	        d) diggy=${OPTARG};;
	        s) source=${OPTARG};;
	        v) echo "V.0.2"
	           exit;;
	        h) Help 
	           exit;;
	    esac
	done
digstring()
{

for (( i = 1; i <= $diggy; i++ ))
do
	wildcard="[^.*$]*\."
	str=""
	for (( j =1; j <= $i; j++ ))
	do
  		str+="${wildcard}"
	done
	WILD_STRINGS[$i-1]="$str$source"
done
}
digstring
###################################################################################################################################################################

#------------------> CRTSH RECON
Level_Domains_crt=($source)
extract_crt()
{
for sdm in ${Level_Domains_crt[@]}
do
	for domains in `curl -s https://crt.sh/?Identity=%.$sdm | grep ">*.$sdm" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$sdm" | sort -u | awk 'NF'`
	do
		echo $domains >> ./"$source"/"$source"_crt.txt
		for items in `echo $domains | grep -o ${WILD_STRINGS[$1-1]}`
		do
			check=$(Level_Unique_crt $items)
			if [[ $check != 1 ]] ; then
				Temporary_Domains_crt+=($items)
			fi
		done
	done
	
done
}

level_crt()
{
for (( level=1;level<=$diggy;level++))
do

	echo -n "$level-->"
	extract_crt $level
	unset Level_Domains_crt
	Level_Domains_crt=${Temporary_Domains_crt[@]}
	unset Temporary_Domains_crt
done
}

###################################################################################################################################################################

#------------------> FINDOMAIN RECON
Level_Domains_find=($source)
extract_findwrap()
{
for sdm in ${Level_Domains_find[@]}
do
	for domains in `findomain -q -t $sdm 2>/dev/null | sort -u`
	do
		echo $domains >> ./"$source"/"$source"_findomain.txt
		for items in `echo $domains  | grep -o ${WILD_STRINGS[$1-1]}`
		do
			check=$(Level_Unique_find $items)
			if [[ $check != 1 ]] ; then
				Temporary_Domains_find+=($items)
			fi
		done
	done
	
done
}

level_findwrap()
{
for (( level=1;level<=$diggy;level++))
do

	echo -n "$level-->"
	extract_findwrap $level
	unset Level_Domains_find
	Level_Domains_find=${Temporary_Domains_find[@]}
	unset Temporary_Domains_find
done
}


###################################################################################################################################################################

#------------------> SUBFINDER RECON
Level_Domains_sub=($source)
extract_subfinder()
{
for sdm in ${Level_Domains_sub[@]}
do
	for domains in `subfinder -silent -d $sdm`
	do
		echo $domains >> ./"$source"/"$source"_subfinder.txt
		for items in `echo $domains | grep -o ${WILD_STRINGS[$1-1]}`
		do
			check=$(Level_Unique_sub $items)
			if [[ $check != 1 ]] ; then
				Temporary_Domains_sub+=($items)
			fi
		done
	done
	
done
}

level_subfinder()
{
for (( level=1;level<=$diggy;level++))
do

	echo -n "$level-->"
	extract_subfinder $level
	unset Level_Domains_sub
	Level_Domains_sub=${Temporary_Domains_sub[@]}
	unset Temporary_Domains_sub
done
}

###################################################################################################################################################################

#------------------> Buffer Over Run RECON
Level_Domains_buffer=($source)
extract_buffer()
{
for sdm in ${Level_Domains_buffer[@]}
do
	for domains in `curl -s https://tls.bufferover.run/dns?q=$sdm | jq .Results[] 2>/dev/null | cut -d ',' -f 3 | sed 's/*//g' | sed 's/\"//g' | sort -u `
	do
		echo $domains >> ./"$source"/"$source"_buffer.txt
		for items in `echo $domains | grep -o ${WILD_STRINGS[$1-1]}`
		do
			check=$(Level_Unique_buffer $items)
			if [[ $check != 1 ]] ; then
				Temporary_Domains_buffer+=($items)
			fi
		done
	done
	
done
}
level_buffer()
{
for (( level=1;level<=$diggy;level++))
do

	echo -n "$level-->"
	extract_buffer $level
	unset Level_Domains_buffer
	Level_Domains_buffer=${Temporary_Domains_buffer[@]}
	unset Temporary_Domains_buffer
done
}
###################################################################################################################################################################


main()
{
mkdir ./"$source"
echo "CERTSH EXTRACTION"
level_crt
echo "end"
echo "FINDWRAP EXTRACTION​"
level_findwrap
echo "end"
echo "SUBFINDER EXTRACTION"
level_subfinder
echo "end"
echo "BUFFEROVERRUN EXTRACTION"
level_buffer
echo "end"
file_organize
}
main



