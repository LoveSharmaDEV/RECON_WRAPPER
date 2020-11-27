declare -a WILD_STRINGS
declare -a Temporary_Domains
declare -a Level_Domains
Level_Domains=($source)
Level_Unique()
{
	for i in ${Temporary_Domains[@]} ; 
	do
       		if [ $i == $1 ] ; then
        	    echo "1"
        	fi
       done		
}
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
	        v) echo "V.0"
	           exit;;
	        h) Help 
	           exit;;
	    esac
	done
	
	
###################################################################################################################################################################

#------------------> CRTSH RECON

extract()
{
for sdm in ${Level_Domains[@]}
do
	echo "PERFORMING LEVEL $1 EXTRACTION ON --------------> $sdm"	
	for domains in `curl -s https://crt.sh/?Identity=%.$sdm | grep ">*.$sdm" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$sdm" | sort -u | awk 'NF'`
	do
		echo $domains >> all.txt
		for items in `echo $domains | grep -o ${WILD_STRINGS[$1-1]}`
		do
			check=$(Level_Unique $items)
			if [[ $check != 1 ]] ; then
				Temporary_Domains+=($items)
			fi
		done
	done
	
done
}

for (( level=1;level<=$diggy;level++))
do

	echo "Extracting Level $level"
	extract $level
	unset Level_Domains
	Level_Domains=${Temporary_Domains[@]}
	unset Temporary_Domains
done


