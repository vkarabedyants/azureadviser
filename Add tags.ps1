Clear-Host
$source       = './prod.txt'
$resourcepath = '/subscriptions/63898ca7-fd62-4bb6-b352-c88eb6b3adb2/resourceGroups'
az account set --subscription '63898ca7-fd62-4bb6-b352-c88eb6b3adb2'

Get-Content $source | ForEach-Object -Begin {$i = 1} -Process {
    $rgname   = ($_.replace('`n', "") -split '	')[0]
    $tag1     = ($_.replace('`n', "") -split '	')[1]
    $tag2     = ($_.replace('`n', "") -split '	')[2]
    $tag3     = ($_.replace('`n', "") -split '	')[3]
    $tag4     = ($_.replace('`n', "") -split '	')[4]
    Write-Host "Resource Group: $rgname  Tags: $tag1 $tag2 $tag3 $tag4"
    $value
    az tag update --resource-id $resourcepath/$rgname --tags $tag1 $tag2 $tag3 $tag4 --operation merge --only-show-errors --output none
    $ResIdList = (az resource list --resource-group $rgname | ConvertFrom-Json).id
    foreach ($ResId in $ResIdList){
        Write-Host ($ResId -split '/')[-1]
        az tag update --resource-id $ResId --tags $tag1 $tag2 $tag3 $tag4 --operation merge --only-show-errors --output none
    }
    $i++ 
}