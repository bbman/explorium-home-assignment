#!/bin/bash


# checking SG
aws ec2 describe-security-groups --query "SecurityGroups[*]" > aws-sg.json
SG=$(jq -c '.[]' aws-sg.json)
sgArgs=()
for i in $SG
do
	#Go over Description
	# FILTERING: 3 numbers & not PROD in Description text
	desc=$(echo "$i" | jq '.Description')
	sgId=$(echo "$i" | jq '.GroupId')
	ncount="${desc//[^[:digit:]]/}"
	numcount=$(echo ${#ncount})

	# FILTERING: 3 numbers & not PROD in Description text
	if (( numcount > 2 )); then 
		printf "[SG][$sgId] Description text: $desc\n"
		printf "[SG][$sgId] number count: $numcount\n"
		printf "[SG][$sgId] $desc has more the 3 numbers in the Description text\n"
		
		if [[ $desc == *"prod"* ]]; then
			printf "[SG][$sgId] This is prod SG!!!, skipping..."
		else
			printf "[SG][$sgId] adding $desc to SG array\n\n"
			sgArgs+=("$i")
		fi
	fi
done
printf "\nlist of relavent SG\n"
printf "%s\n\n" "${sgArgs[@]}"

printf "\ndone with SG loop\n"

# checking elb relations
aws elbv2 describe-load-balancers --query "LoadBalancers" > elb.json
ELB=$(jq -c '.[]' elb.json)
elbArgs=()
elbSGArgs=()
finalSGArgs=()
printf "working with LoadBalancers\n\n"
for i in $ELB
do
	# Check if ELB Instances is 0
	hasInst=$(echo "$i" | jq '.Instances')
	if [ $hasInst = null  ]
	then
		elbArgs+=("$i")
		elbName=$(echo "$i" | jq '.LoadBalancerName')
		elbSGIds=$(echo "$i" | jq '.SecurityGroups')
		elbSGcount=$(echo "$i" | jq '.SecurityGroups | length')
		
		printf "[ELB] LoadBalancer : $elbName has 0 Instances\n"
		
		printf "[ELB][$elbName] working on $elbName ELB-SG:"
		echo $elbSGIds
		echo

		let "elbSGcount=elbSGcount-1"
		for x in $(seq 0 $elbSGcount)
		do
			elbSGId=$(echo "$i" | jq '.SecurityGroups['$x']')

			for sg in "${sgArgs[@]}"
			do 
				sgId=$(echo "$sg" | jq '.GroupId')
				printf "[ELB] checking $elbSGId with SG list\n"
				if [ $sgId = $elbSGId ]
				then
					printf "[ELB] Is a Match\n"
					printf "[ELB] Addin sg to array - $sgId\n"
					finalSGArgs+=("$sg")
				else
					printf "[ELB] No Match\n"
				fi
			done
		done
	else
		printf "$hasInst is NOT NULL, moving on.."
	fi
done

echo
echo "The SG that will be deleted:"
printf "%s\n" "${finalSGArgs[@]}"
echo
for i in $finalSGArgs
do
	sgId=$(echo "$i" | jq '.GroupId')

	#DELETE SG
	#aws ec2 delete-security-group --group-id $sgId
	echo "aws ec2 delete-security-group --group-id $sgId"
done