##========================================================
#
# TODO: Updated: 2019-07-20
#
# Step 0 - Setup TARGET Server and Credential Variables

ping 10.x.y.90 #VMHost vmh01 iLO
ping 10.x.y.91 #VMHost vmh02 iLO

$Find_ILOs = Find-HPiLO "10.10.224" # Use the first 3 Octets here

# $Find_ILOs = Find-HPiLO "10.250.75" # Use the first 3 Octets here

$Find_ILOs

    $ILO = ($Find_ILOs | where { $_.IP -match '101'})

    $ILO_IP = $ILO.IP

    $ILO_IP

$ILO_User = 'Administrator'
$ILO_UserPassword = 'S0m3_P@55W0rd1' # Blank it out now


$ILO_IP

$HPiLO_Credential = Get-Credential -UserName $ILO_User -Message 'HP iLO Username and Password'



$HPiLO_Server_Credential = @{

    Server     = $ILO_IP
    Credential = $HPiLO_Credential
}

$HPEiLO_Server_Credential = @{

    IP         = $ILO_IP
    Credential = $HPiLO_Credential
}



Get-HPServerPowerState @HPiLO_Server_Credential

##========================================================

# Step 1 - of Invoke-HPEInitialConfigG9

$Step = 1

Write-Host "STEP = $Step --> Power Off HP Server"

$Date = Get-Date

$Date.DateTime

$HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

PowerOff-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false

$date = get-date

$date.DateTime

##========================================================

Disconnect-HPEBIOS -Connection $HPEBiosSession

# Build New HPSession to modify BIOS

$HPEBiosSession = Connect-HPEBIOS @HPEiLO_Server_Credential -AdminPassword 'Du8!0s@dm!n' -DisableCertificateAuthentication

Set-HPEBIOSAdminPassword -Connection $HPEBiosSession -OldAdminPassword 'Du8!0s@dm!n' -NewAdminPassword '' -Verbose



##========================================================
#
# Step 1.1 - Get MFG Reset File for HP G9

$Step++

Write-Host "STEP = $Step --> Get MFG Reset File for HP G9"

$Date = Get-Date

$Date.DateTime

$path = 'C:\Presentation\2019\2019-07\Applying-HPE-PowerShell-Toolkit\Json\' # Need to change to relative path or network path

# New HPE Bios

$MfgResetHPEBiosJsonFile = 'HPE-DL360-G9_BIOS_Reset-to-MFG-settings_2018-05-28.json'

$MfgResetHPEBiosHash = (Get-ChildItem $path $MfgResetHPEBiosJsonFile | Get-Content -raw | ConvertFrom-Json)

##========================================================
#
# Step 1.2 - Get vNext Bios File for HP G9

$path = 'C:\Presentation\2019\2019-07\Applying-HPE-PowerShell-Toolkit\Json\' # Need to change to relative path or network path

$vNextHPEBiosJsonFile = 'HPE-DL360-G9_BIOS_vNext_2018-05-30.json'

$vNextHPEBiosHash = (Get-ChildItem $path $vNextHPEBiosJsonFile | Get-Content -raw | ConvertFrom-Json)

##========================================================
#
# Step 2.1 - Power Off HP Server

$Step++
Write-Host "STEP = $Step --> Power Off HP Server"

$Date = Get-Date

$Date.DateTime

$HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

PowerOff-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false

$date = get-date

$date.DateTime

Disconnect-HPEBIOS $HPEBiosSession

$HPEBiosSession = Connect-HPEBIOS @HPEiLO_Server_Credential -AdminPassword 'Du8!0s@dm!n' -DisableCertificateAuthentication

$UpdateHPEBiosPassword = (Set-HPEBIOSAdminPassword -Connection $HPEBiosSession -OldAdminPassword 'Du8!0s@dm!n' -NewAdminPassword '' -Verbose | Format-List)

##========================================================
#
# Step 3.1 - Clear HPSession

$Step++
Write-Host "STEP = $Step --> Clear HPSession / Build New HPSession"

# Remove-HpSession $HPSession

Disconnect-HPEBIOS $HPEBiosSession

##========================================================
#
# Step 3.2 - Build New HPSession to modify BIOS

$HPEBiosSession = Connect-HPEBIOS @HPEiLO_Server_Credential -AdminPassword 'Du8!0s@dm!n' -DisableCertificateAuthentication

##========================================================
#
# Step 4 - Gather Current BIOS Settings

$Step++
Write-Host "STEP = $Step --> Gather Current BIOS Settings"

# $testHash = Get-HPServerBiosContent -IP $ILO_IP -Session $HPSession -Output Hash

$HPEBIOSSetting = Get-HPEBIOSSetting -Connection $HPEBiosSession

#---New Change

$HPEBiosSession = Connect-HPEBIOS @HPEiLO_Server_Credential -AdminPassword '' -DisableCertificateAuthentication

Set-HPEBIOSAdminPassword -Connection $HPEBiosSession -OldAdminPassword '' -NewAdminPassword 'Du8!0s@dm!n' -Verbose | Format-List

#---End New Change

$HPEBIOSSettingHash = $HPEBIOSSetting.CurrentBIOSSettings

$HPEPendingBiosSettingHash = $HPEBIOSSetting.PendingBIOSSettings

$HPEPendingBiosSettingHash.BootMode

$HPEPendingBiosSettingHash.ResetDefaultManufacturingSetting

##========================================================
#
# Step 6 - Power On HP Server

$Step++
Write-Host "STEP = $Step --> Power On HP Server"

$HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

PowerOn-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false

##========================================================
#
# Step 7.1 -  Clear HPSession

$Step++
Write-Host "STEP = $Step --> Clear HPSession / Build New HPSession"

# Remove-HpSession $HPSession


Disconnect-HPEBIOS -Connection $HPEBiosSession


##========================================================
#
# Step 7.2 -  Build New HPSession to modify BIOS

$HPEBiosSession = Connect-HPEBIOS @HPEiLO_Server_Credential -AdminPassword 'Du8!0s@dm!n' -DisableCertificateAuthentication

# Command for HPE Bios 2.55 and up

Reset-HPEBIOSDefaultManufacturingSetting -Connection $HPEBiosSession -ResetDefaultManufacturingSetting

$HPEBIOSSetting = Get-HPEBIOSSetting -Connection $HPEBiosSession

$HPEBIOSSettingHash = $HPEBIOSSetting.CurrentBIOSSettings

$HPEPendingBiosSettingHash = $HPEBIOSSetting.PendingBIOSSettings

$HPEPendingBiosSettingHash.BootMode

$HPEPendingBiosSettingHash.ResetDefaultManufacturingSetting

##========================================================
#
# Step 8.1 - Setup Function to gather Key Bios Entries Hash

$Step++
Write-Host "STEP = $Step --> Setup Function to gather Key Bios Entries Hash"

## Odd Question - Is there any powerShell Command or script that will let you walk a Hash Table and add in all of items in Name Field to an array?

# Array Defining Key BIOS Entries that I care about.

# New HPE Bios

$KeyHPEBiosEntries = @("BootMode", "ResetDefaultManufacturingSetting", "PowerProfile", "ServerPrimaryOs", "ServerOtherInfo")

# Empty Hash Table - will be used to store information about the Key BIOS Entries

# if this were a function --> it would accept a Full BIOS Hash ($testHash) and BIOS Entries that Matter ($KeyBiosEntries)

##========================================================
#
# Step 8.2 - Setup Function to gather Key Bios Entries Hash


##========================================================
#
# Step 8.3 - Call Function to gather Key Bios Entries Hash

# New HPE Bios

$HPEBiosEntryHash = Get-MyHPEBiosEntryHash -HPEBiosHash $MfgResetHPEBiosHash -MyKeyBiosEntries $KeyHPEBiosEntries


$HPEBiosEntryHash.BootMode

$HPEPendingBiosSettingHash.ResetDefaultManufacturingSetting

##========================================================
#
# Step 9 - Do loop to Compare settings

$Step++
Write-Host "STEP = $Step --> Do loop to Compare Current settings to MFG Restore Bios Json File"

# Compare-HPEServerBiosContent -IP $ILO_IP -User $ILO_User -Password $ILO_UserPassword -HPEServerBiosContentHash $HPEBiosEntryHash -KeyBiosEntries $KeyHPEBiosEntries -TryCount 5 -Verbose

Compare-HPEServerBiosContent -IP $ILO_IP -User $ILO_User -Password $ILO_UserPassword -HPEServerBiosContentHash $HPEBiosEntryHash -KeyBiosEntries $KeyHPEBiosEntries -TryCount 10 -Verbose

# Initially tested this far Tuesday, May 29, 2018 6:21:15 PM

##========================================================
#
# Step 10 - # Power Off HP Server

$Step++
Write-Host "STEP = $Step --> Power Off HP Server"

$HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

PowerOff-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false

##========================================================
#
# Step 11.1 - Clear HPSession

$Step++
Write-Host "STEP = $Step --> Clear HPSession / Build New HPSession"

Disconnect-HPEBIOS -Connection $HPEBiosSession





##========================================================
#
# Step 11.2 - Build New HPSession to modify BIOS

$HPEBiosSession = Connect-HPEBIOS @HPEiLO_Server_Credential -AdminPassword 'Du8!0s@dm!n' -DisableCertificateAuthentication

$Date = Get-Date

$Date.DateTime

##========================================================
#
#  Setup vNext Json Variable
# Step 12 - Apply vNext BIOS Settings

$Step++
Write-Host "STEP = $Step --> Apply vNext BIOS Settings"

Set-HPEBIOSBootMode -Connection $HPEBiosSession -BootMode LegacyBIOSMode
Set-HPEBIOSPowerProfile -Connection $HPEBiosSession -PowerProfile MaximumPerformance
Set-HPEBIOSServerInfo -Connection $HPEBiosSession -ServerPrimaryOS 'VMware ESXi 6.0 U2'
Set-HPEBIOSServerInfo -Connection $HPEBiosSession -ServerOtherInfo 'vNext 2018'

##========================================================
#
# Step 13 - Do loop to Compare settings

$Step++
Write-Host "STEP = $Step --> Do loop to Compare settings"

$vNextHPEBiosHash

$HPEBiosEntryHash = Get-MyHPEBiosEntryHash -HPEBiosHash $vNextHPEBiosHash -MyKeyBiosEntries $KeyHPEBiosEntries

##========================================================
#
# Step 14 - Power On HP Server

$Step++
Write-Host "STEP = $Step --> Power On HP Server"

$HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

PowerOn-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false



$HPEBIOSSetting = Get-HPEBIOSSetting -Connection $HPEBiosSession

$HPEBIOSSettingHash = $HPEBIOSSetting.CurrentBIOSSettings

$HPEPendingBiosSettingHash = $HPEBIOSSetting.PendingBIOSSettings

$HPEPendingBiosSettingHash.BootMode

$HPEPendingBiosSettingHash.ResetDefaultManufacturingSetting

##========================================================
#
# Step 15 - Do loop to Compare settings

$Step++
Write-Host "STEP = $Step --> Do loop to Compare Current settings to vNext Bios Json File"

# Compare-HPServerBiosContent -HPServerBiosContentHash $HPBiosEntryHash -KeyBiosEntries $KeyBiosEntries -TryCount 10

Compare-HPEServerBiosContent -IP $ILO_IP -User $ILO_User -Password $ILO_UserPassword -HPEServerBiosContentHash $HPEBiosEntryHash -KeyBiosEntries $KeyHPEBiosEntries -TryCount 10 -Verbose

# Testing to Here 05-30-2018, 1:09 AM ==========


##========================================================
#
# Step 15.1 - # Power Off HP Server


$Process = Get-Process -Name * | where { $_.ProcessName -eq 'IRC' }

$Process

Stop-Process $Process

$HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

PowerOff-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false



##========================================================
#
# Step 15.2 - Set BIOS Admin Password

<#
Disconnect-HPEBIOS -Connection $HPEBiosSession

# Build New HPSession to modify BIOS

##---DELETE ME---## $HPEBiosSession = Connect-HPEBIOS @HPEiLO_Server_Credential -AdminPassword 'Du8!0s@dm!n' -DisableCertificateAuthentication

##---DELETE ME---## Set-HPEBIOSAdminPassword -Connection $HPEBiosSession -OldAdminPassword 'Du8!0s@dm!n' -NewAdminPassword 'NewPass' -Verbose

#>

##========================================================
#
# Step   Power On

$Step++
Write-Host "STEP = $Step --> Check Boot Mode and Boot Order"

$HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

PowerOn-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false

##========================================================



Disconnect-HPEBIOS -Connection $HPEBiosSession

$HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

PowerOff-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false

PowerOn-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false

# Build New HPSession to modify BIOS

$HPEBiosSession = Connect-HPEBIOS @HPEiLO_Server_Credential -AdminPassword 'Du8!0s@dm!n' -DisableCertificateAuthentication

$HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

PowerOff-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false

##========================================================
#
# Step 15.1 - # Power Off HP Server


$Process = Get-Process -Name * | where { $_.ProcessName -eq 'IRC' }

$Process

Stop-Process $Process

$HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

PowerOff-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false


$HPiLOPendingBootMode = Set-HPiLOPendingBootMode @HPiLO_Server_Credential -BootMode LEGACY -DisableCertificateAuthentication


#Get-help Reset-HPEBIOSAdminPassword -Examples

#

Disconnect-HPEBIOS -Connection $HPEBiosSession

$HPEBIOSSetting = Get-HPEBIOSSetting -Connection $HPEBiosSession

$HPEBIOSSettingHash = $HPEBIOSSetting.CurrentBIOSSettings

$HPEPendingBiosSettingHash = $HPEBIOSSetting.PendingBIOSSettings

$HPEPendingBiosSettingHash.


##========================================================
#
# Step 16 - Check Boot Mode and Boot Order

$Step++
Write-Host "STEP = $Step --> Check Boot Mode and Boot Order"

$HPCurrentBootMode = Get-HPCurrentBootMode @HPiLO_Server_Credential

$HPiLOPendingBootMode = Set-HPiLOPendingBootMode @HPiLO_Server_Credential -BootMode LEGACY -DisableCertificateAuthentication


$Step++
Write-Host "STEP = $Step --> Power Off HP Server"

$HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

PowerOff-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false



$Step++
Write-Host "STEP = $Step --> Power On HP Server"

$HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

PowerOn-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false

# Set-HPiLOPendingBootMode @HPiLO_Server_Credential -BootMode UEFI -DisableCertificateAuthentication

$HPPendingBootMode = Get-HPPendingBootMode @HPiLO_Server_Credential

$Date = Get-Date

$Date.DateTime

$HPBootModeHashTable = Get-HPBootModeHashTable @HPiLO_Server_Credential -HPCurrentBootMode $HPCurrentBootMode -HPPendingBootMode $HPPendingBootMode

$HPBootModeHashTable.HPCurrentBootOrder

##========================================================
#
# Step 17 - # Power Off HP Server

# Added 2017-11-02, 1:14 PM

# Added 2017-11-02, 2:40 PM

$Step++
Write-Host "STEP = $Step --> Power Off HP Server"

$HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

PowerOff-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false


##========================================================
#
# Step 18 - Configure Boot Order

$Step++
Write-Host "STEP = $Step --> Configure Boot Order"

$Date = Get-Date

$Date.DateTime

$HPStartBootOrderString = "NETWORK,USB,HDD,CDROM"

$TestBootOrder = Invoke-HPBootOrderConfig @HPiLO_Server_Credential -MyHPBootOrder $HPStartBootOrderString

$TestBootOrder

Start-Sleep -Seconds 30

$HPiLOPersistentBootOrder = Set-HPiLOPersistentBootOrder @HPiLO_Server_Credential -BootOrder @($TestBootOrder) -DisableCertificateAuthentication

$HPCurrentBootOrder = Get-HPCurrentBootOrder @HPiLO_Server_Credential

##========================================================
#
# Step 19 - Set BIOS Admin Password

$Step++
Write-Host "STEP = $Step --> Depreciated - Set Admin Password"

##========================================================
#
# Step 20 - Power On HP Server

$Step++
Write-Host "STEP = $Step --> Power On HP Server"

$Date = Get-Date

$Date.DateTime

$HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

$PowerOnHPServer = PowerOn-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false

$Date = Get-Date

$Date.DateTime

##========================================================
#
# Step 21 - Verify Boot Order is changed
# I am looking for an odd condition that seems to only come up after the BIOS is modified.
#
# The condition puts all BootOrder into a state where it orders them: "CDROOM,HDD,USB,NETWORK" after the BIOS is updated
#
#

$Step++
Write-Host "STEP = $Step --> Verify Boot Order is changed"

$BootNumberCheck = 0
[bool]$BootOrderStable = $false

do {
    Write-Host "STEP = $Step --> Verify Boot Order is changed"

    Write-Verbose "Waiting for 30 Seconds to start check"
    Start-Sleep -Seconds 30
    $HPiLOPersistentBootOrder = Set-HPiLOPersistentBootOrder @HPiLO_Server_Credential -BootOrder @($TestBootOrder) -DisableCertificateAuthentication
    $HPCurrentBootOrder = Get-HPCurrentBootOrder @HPiLO_Server_Credential
    $HPCurrentBootOrder

    if (!($HPiLOPersistentBootOrder)) {
        Write-Host "`$HPiLOPersistentBootOrder is now unset"

        if ($BootNumberCheck -gt 3) {
            $BootOrderStable = $true

        }
    }
    else {
        if ($HPiLOPersistentBootOrder.STATUS_MESSAGE -match 'POST in progress') {
            $HPiLOPersistentBootOrder

            Write-Host "`$HPiLOPersistentBootOrder is still being checked"
        }
    }
    $BootNumberCheck++
}
while ($BootOrderStable -eq $false)

##========================================================
#
# Step 22 - # Power Off HP Server

$Step++
Write-Host "STEP = $Step --> Power Off HP Server"

$HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

PowerOff-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false

##========================================================
#
# Step 23 - # Power On HP Server

$Step++
Write-Host "STEP = $Step --> Power On HP Server"

$HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

PowerOn-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false

$Date = Get-Date

$Date.DateTime

# ---END of Invoke-HPEInitialConfigG9
