$tenantId="72f988bf-86f1-41af-91ab-2d7cd011db47"
$subscriptionId="eeb84c6a-7753-4a8a-b39e-d66612be62a0"
$resourceGroup="sdubey-stig"
$storageAccountName="sdubeystig1"
$filesContainer="files"
$scriptsContainer="scripts"

$acureDeployFile="azuredeploy.json"
$createUIDefFile="createUiDefinition.json"

#Set-AzContext -Tenant $tenantId -SubscriptionId $subscriptionId
$context = (Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName).Context

#New-AzStorageContainer -Name $filesContainer -Context $context -Permission Off
#New-AzStorageContainer -Name $scriptsContainer -Context $context -Permission Container

Set-AzStorageBlobContent -File ".\azuredeploy.json" -Container $filesContainer -Blob "azuredeploy.json" -Context $context -Force
Set-AzStorageBlobContent -File ".\createUiDefinition.json" -Container $filesContainer -Blob "createUiDefinition.json" -Context $context -Force
Set-AzStorageBlobContent -File ".\scripts\InstallModules.ps1" -Container $scriptsContainer -Blob "InstallModules.ps1" -Context $context -Force
Set-AzStorageBlobContent -File ".\scripts\RequiredModules.ps1" -Container $scriptsContainer -Blob "RequiredModules.ps1" -Context $context -Force
Set-AzStorageBlobContent -File ".\scripts\WindowsServer.ps1.zip" -Container $scriptsContainer -Blob "WindowsServer.ps1.zip" -Context $context -Force

$azureDeployUrl = New-AzStorageBlobSASToken -Container $filesContainer -Blob (Split-Path $acureDeployFile -leaf) -Context $context -FullUri -Permission r
$createUIDefUrl = New-AzStorageBlobSASToken -Container $filesContainer -Blob (Split-Path $createUIDefFile -leaf) -Context $context -FullUri -Permission r

$azureDeployUrlEncoded=[uri]::EscapeDataString($azureDeployUrl)
$createUIDefUrlEncoded=[uri]::EscapeDataString($createUIDefUrl)
$deployUrl="https://portal.azure.com/#create/Microsoft.Template/uri/$($azureDeployUrlEncoded)/createUIDefinitionUri/$($createUIDefUrlEncoded)"
$deployUrl