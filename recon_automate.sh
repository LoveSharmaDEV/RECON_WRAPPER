###################################################################################################################################################################
declare -a WILD_STRINGS
declare -a Temporary_Domains_crt
declare -a Level_Domains_crt
declare -a Temporary_Domains_find
declare -a Level_Domains_find
declare -a Temporary_Domains_sub
declare -a Level_Domains_sub

file_organize()
{
	cat all_crt.txt | sort -u >>  all_crt_final.txt
	cat all_findomain.txt | sort -u >> all_findomain_final.txt
	cat all_subfinder.txt | sort -u >>  all_subfinder_final.txt
	cat all_crt_final.txt all_findomain_final.txt all_subfinder_final.txt > all.txt
	cat all.txt | sort -u >> all_final.txt
	rm all_crt.txt all_findomain.txt all_subfinder.txt all.txt
}
Level_Unique()
{
	for i in ${Temporary_Domains_crt[@]} ; 
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
	        v) echo "V.0.1"
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
	echo "PERFORMING LEVEL $1 EXTRACTION ON --------------> $sdm"	
	for domains in `curl -s https://crt.sh/?Identity=%.$sdm | grep ">*.$sdm" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$sdm" | sort -u | awk 'NF'`
	do
		echo $domains >> all_crt.txt
		for items in `echo $domains | grep -o ${WILD_STRINGS[$1-1]}`
		do
			check=$(Level_Unique $items)
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

	echo "Extracting Level $level"
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
	echo "PERFORMING LEVEL $1 EXTRACTION ON --------------> $sdm"	
	for domains in `findomain -q -t $sdm 2>/dev/null | sort -u`
	do
		echo $domains >> all_findomain.txt
		for items in `echo $domains  | grep -o ${WILD_STRINGS[$1-1]}`
		do
			check=$(Level_Unique $items)
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

	echo "Extracting Level $level"
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
	echo "PERFORMING LEVEL $1 EXTRACTION ON --------------> $sdm"	
	for domains in `subfinder -silent -d $sdm`
	do
		echo $domains >> all_subfinder.txt
		for items in `echo $domains | grep -o ${WILD_STRINGS[$1-1]}`
		do
			check=$(Level_Unique $items)
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

	echo "Extracting Level $level"
	extract_subfinder $level
	unset Level_Domains_sub
	Level_Domains_sub=${Temporary_Domains_sub[@]}
	unset Temporary_Domains_sub
done
}

###################################################################################################################################################################

level_crt
level_findwrap
level_subfinder
file_organize





