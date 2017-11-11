#!/bin/bash
set -e -o pipefail
src_region=southcentralus
dest_region=westus2

group=${USER}-imaging
src_group=$group
dest_group=$group

#Name image including region it lives in.  This isn't a requirement, just a convention.
image=20171111
src_image=${image}-$src_region
dest_image=${image}-$dest_region

dest_storage=${USER}images$dest_region #Must be globally unique

#Get the disk name from the image name
disk=$(az image show -g $src_group -n $src_image --query storageProfile.osDisk.managedDisk.id -o tsv)
echo "Source image disk $disk"
#Get a shared access signature
sas="$(az disk grant-access -g $src_group --duration-in-seconds 7200 -n $(cut -d / -f 9 <<<$disk) --query accessSas -o tsv)"

echo "Creating storage $dest_storage in $dest_region"
#az group create -l $dest_region --name $dest_group
#Create a destination storage account
az storage account create -g $dest_group --name $dest_storage --sku Standard_LRS --kind Storage -l $dest_region
export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -g $dest_group -n $dest_storage --query connectionString -o tsv)
az storage container create --name vhds

#Copy!
#The file has to end with .vhd!
az storage blob copy start --source-uri "$sas" --destination-blob ${image}.vhd --destination-container vhds

#Wait for copy to complete
while sleep 2; do
  status=$(az storage blob show --container-name vhds -n $image.vhd --query properties.copy -o tsv)
  code=$(cut -f 5 <<<"$status")
  if [ "$code" == "pending" ]; then
    echo -e -n "copy progress $(cut -f 3 <<<"$status")\r"
  elif [ "$code" == "failed" ]; then
    echo
    echo "Copy failed"
    return 1
  else
    echo
    break
  fi
done

az snapshot create -g $dest_group -n $dest_image -l $dest_region --source https://${dest_storage}.blob.core.windows.net/vhds/${image}.vhd
az image create -g $dest_group -n $dest_image --os-type Linux --source /subscriptions/$(cut -d \" -f 6 ~/.azure/azureProfile.json)/resourceGroups/$dest_group/providers/Microsoft.Compute/snapshots/$image -l $dest_region

