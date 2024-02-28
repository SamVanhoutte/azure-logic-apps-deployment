param ($rootFolder, $location, $environmentAcronym)


Function Deploy-LogicAppDefinition($logicAppDefinitionFile, $location, $environmentAcronym, $locationAcronym)
{
    # This function takes a given workflow definition file 
    # and deploys it to the resource group 
    # (based on the folder, location & environment)
    # It will create or update the Logic App

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
    $resourceGroupName = "$environmentAcronym-$locationAcronym-logapp-rg-int-$logicAppType"

    $existingRG = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
    if(-Not $existingRG)
    {
        Write-Host "Creating resource group $resourceGroupName"   
        New-AzResourceGroup -Name $resourceGroupName -Location 'West Europe' -Force
    }

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

}


switch ($location)
{
    'westeurope' { $locationAcronym = 'weu'}
    'northeurope' { $locationAcronym = 'neu'}
    'westus' { $locationAcronym = 'wus'}
    default { $locationAcronym = 'weu'}
}

# Construct workflow definition path
# $scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
# $root = (get-item $scriptPath ).parent.parent
# $workflowDefinitionFile = Join-Path $root 'integrations/ops/metering/weu-dev-int-la-metering-bel-fluvius.definition.json'

Get-ChildItem -Path $rootFolder -Recurse -Filter *.definition.json |
    ForEach-Object {
        # & ./deploy-logicapp.ps1 -logicAppDefinitionFile $_.FullName -location $location -locationAcronym $locationAcronym -environmentAcronym $environmentAcronym
        Deploy-LogicAppDefinition $_.FullName $location $locationAcronym $environmentAcronym
    }