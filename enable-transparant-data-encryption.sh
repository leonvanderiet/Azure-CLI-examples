#!/bin/bash
while getopts s:g: option
do
case "${option}"
in
  s) DATABASE_SERVER=${OPTARG};;
  g) RESOURCE_GROUP=${OPTARG};;
  \?)
   echo "Invalid option: -$OPTARG" >&2
  ;;
esac
done

if [ -z "$DATABASE_SERVER" ]; then
   echo "no database server specified"
   exit
fi

if [ -z "$RESOURCE_GROUP" ]; then
   echo "no resource group specified"
   exit
fi

ids=$(az sql db list --resource-group $RESOURCE_GROUP --server $DATABASE_SERVER --query "[].id" --output tsv)
unencrypted=$(az sql db tde show --ids $ids --query "[?status == 'Disabled'].id" --output tsv)
if [ ! -z "$unencrypted" ] 
then  
	az sql db tde set --status Enabled --ids $unencrypted
fi
