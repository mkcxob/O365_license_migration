#To ensure you are not currently logged into another/wrong Tenant
Disconnect-Graph

#Connects to Microsoft - will require Admin credentials
Connect-Graph -Scopes User.Read.All, Organization.Read.All, AuditLog.Read.All

#Command to get licenses client is currently subscribed to
#Get-MgSubscribedSku | Select-Object -Property Sku*, ConsumedUnits -ExpandProperty PrepaidUnits | Format-List

#License that you want to remove
$e5Sku = Get-MgSubscribedSku -All | Where-Object SkuPartNumber -eq 'STANDARDWOFFPACK'

#License that you want to add
$new_license = Get-MgSubscribedSku -All | Where-Object SkuPartNumber -eq 'O365_BUSINESS_ESSENTIALS'

#Retrieve list of user ids with the license you want to remove
$user_ids = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($e5sku.SkuId) )" -ConsistencyLevel eventual -CountVariable licensedUserCount -All | Select-Object -ExpandProperty Id

#Counts amount of users with license
Write-Host "E2 Licensed User Count: $licensedUserCount"

# Loops over list of user ids to add the new license and remove the old
foreach ($item in $user_ids)
{
    Set-MgUserLicense -UserId $item -AddLicenses @{SkuId = $new_license.SkuId} -RemoveLicenses @()
}

Start-Sleep -Seconds 120

foreach ($item in $user_ids)
{
    Set-MgUserLicense -UserId $item -RemoveLicenses @($e5Sku.SkuId) -AddLicenses @{}
}

#Disconnects from Microsoft
Disconnect-Graph
