#!/bin/bash
while getopts g: option
do
case "${option}"
in
  g) RESOURCE_GROUP=${OPTARG};;
  \?)
   echo "Invalid option: -$OPTARG" >&2
  ;;
esac
done

if [ -z "$RESOURCE_GROUP" ]; then
   echo "no resource group specified"
   exit
fi

ids=$(az webapp list -g $RESOURCE_GROUP --query "[].id" --output tsv)
#if [ ! -z "$ids" ]
#then
#	az webapp config set --ids $ids  --generic-configurations "{'ftpsState': 'Disabled'}"
#	slots(az webapp deployment slot list --ids $ids)
#	echo $slots
#fi

for id in $ids
do
	az webapp config set --ids $id  --generic-configurations "{'ftpsState': 'Disabled'}"
	slots=$(az webapp deployment slot list --ids $id --query "[].name" --output tsv)
	for slot in $slots
	do
		az webapp config set --ids $id --slot $slot --generic-configurations "{'ftpsState': 'ftpsOnly'}"
	done
done
