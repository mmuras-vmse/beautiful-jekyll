###========================================================
#
# TODO: Updated: 2019-07-20
#
# Applying the HP / HPE PowerShell Scripting Toolkit
#
# by: Matt Muras
#
# Part 3 - HP - BootMode and BootOrder
#
#=======================================================

# 0. Intro to BootMode

    <#
        On HP and HPE Proliant G9 Servers there are 2 different BootModes:

        UEFI   - This one boots newer stuff

        and

        LEGACY - This one boots older stuff (Legacy stuff)

        Both are useful, but it takes some "mental gymnastics" (as Kevin Marquette would say) to keep these two modes correctly in focus.

            Basically, I use LEGACY when I use TFTP / PXE Boot a Server, so I have to put the server into "LEGACY" BootMode so PXE will work.
    #>

# 1. Get the HP Current BootMode and set it to LEGACY

    $HPCurrentBootMode = Get-HPCurrentBootMode @HPiLO_Server_Credential

    $HPCurrentBootMode

     $HPiLOPendingBootMode = Set-HPiLOPendingBootMode @HPiLO_Server_Credential -BootMode LEGACY -DisableCertificateAuthentication

    $HPiLOPendingBootMode

# Set-HPiLOPendingBootMode @HPiLO_Server_Credential -BootMode UEFI -DisableCertificateAuthentication

# 4.b. Testing Power Off the server with ILO

    $HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

    $HPServerPowerState

    PowerOff-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false

# 4.c. Testing Power On the server with ILO

    $HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

    $HPServerPowerState

    PowerOn-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false

    #

    # While presentation is happening - write do loop for effect

    do {

        $HPCurrentBootMode = Get-HPCurrentBootMode @HPiLO_Server_Credential

    $HPCurrentBootMode

        $HPPendingBootMode = Get-HPPendingBootMode @HPiLO_Server_Credential

    $HPPendingBootMode

    } while($HPCurrentBootMode -eq 'UEFI')

<#

    I spent some time writing out special functions that interact with the BootMode and BootOrder in Q3 / Q4 of 2017.

#>

    $HPStartBootOrderString = "NETWORK,USB,HDD,CDROM"

    $TestBootOrder = Invoke-HPBootOrderConfig @HPiLO_Server_Credential -MyHPBootOrder $HPStartBootOrderString

    $TestBootOrder

    Get-HPBootOrder @HPiLO_Server_Credential

## PART 4 - HP Demo - shows scripts discussed running together to setup a G9 Server

    # Launch Next file of presentation into new ISE tab
	ise .\Part4-HP-Demo.ps1

	# Launch Next file of presentation into new VSCode tab
    code .\Part4-HP-Demo.ps1
	