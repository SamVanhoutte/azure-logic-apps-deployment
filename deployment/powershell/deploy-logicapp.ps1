# This script takes a given workflow definition file 
# and deploys it to the resource group 
# (based on the folder, location & environment)
# It will create or update the Logic App

param ($logicAppDefinitionFile, $location, $environmentAcronym, $locationAcronym)

### SET UP LOGIC APP NAME
# Taking the file name 
$logicAppName = Split-Path $logicAppDefinitionFile -leaf
Write-Host $logicAppName
# and remove the suffix to keep the name
$logicAppName = $logicAppName.Replace('.definition.json', '')
Write-Host $logicAppName
# and construct the full resource name
$logicAppName = "$locationAcronym-$environmentAcronym-int-la-$logicAppName"
Write-Host $logicAppName

### SET UP RESOURCE GROUP NAME
# Taking the directory name to which the json file belongs
$logicAppType = Split-Path (Split-Path $logicAppDefinitionFile -Parent) -Leaf
# and construct the resource group name
$resourceGroupName = "$locationAcronym-$environmentAcronym-rg-int-$logicAppType"

### CRUD OF LOGIC APP DEFINITION
# Check if logic app exists
$existingLogicApp = Get-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName -ErrorAction SilentlyContinue
if($existingLogicApp)
{
    Write-Host "Update logic app $logicAppName to resource group $resourceGroupName"   
    Set-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName -DefinitionFilePath $logicAppDefinitionFile -Force
}
else 
{
    Write-Host "Create logic app $logicAppName to resource group $resourceGroupName"
    New-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName -Location $location -DefinitionFilePath $logicAppDefinitionFile
}