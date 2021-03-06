param (
    [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $ResourceGroup,
    [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $AzureLocation,
    [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $KeyVaultName,
    [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $OpenShiftPassword,
    [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $RhsmPasswordOrActivationKey,

    [ValidateNotNullOrEmpty()]
    [string] $AadClientSecret = "WeDontCareRightNow",

    [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $SshPrivateKey
)

Log-Parameters -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$proc = "az"

Log-Information "Create resource group for KeyVault: $ResourceGroup"
$argList = "group create -l `"$AzureLocation`" -n $ResourceGroup -o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Information "Checking for soft-deleted keyvault with the name, $KeyVaultName"

$softDeletedKeyvault = (az keyvault list-deleted --query "[?name == '$KeyVaultName'].name" -o tsv)
if ($softDeletedKeyvault)
{
    Log-Information "Found a soft-deleted keyvault, $softDeletedKeyvault.  Purging keyvault"
    $argList = "keyvault purge --name $KeyVaultName"
    $retVal = Run-Command -Process $proc -Arguments $argList

    if ($retVal -ne 0)
    {
        Log-Error "There was an error purging the keyvault, $KeyVaultName"
        throw
    }
    else 
    {
        Log-Information "Successfully purged the keyvault, $KeyVaultName"
    }
}

Log-Information "Create the KeyVault"
$argList = "keyvault create -l `"$AzureLocation`" -n $KeyVaultName -g $ResourceGroup --enabled-for-template-deployment true --enabled-for-deployment true -o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Information "Add secret for openshiftpassword"
$argList = "keyvault secret set --vault-name $KeyVaultName -n openshiftPassword --value $OpenShiftPassword -o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Information "Add secret for redhat subscription"
$argList = "keyvault secret set --vault-name $KeyVaultName -n rhsmPasswordOrActivationKey --value $RhsmPasswordOrActivationKey -o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Information "Add secret for AAD"
$argList = "keyvault secret set --vault-name $KeyVaultName -n aadClientSecret --value $AadClientSecret -o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Information "Add secret for sshPrivateKey"
$argList = "keyvault secret set --vault-name $KeyVaultName -n sshPrivateKey --file `"$($(Get-Location).Path)/certs/$SshPrivateKey`" -o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Footer -ScriptName $MyInvocation.MyCommand
