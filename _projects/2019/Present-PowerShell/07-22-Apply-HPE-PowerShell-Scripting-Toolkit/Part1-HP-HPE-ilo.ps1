###========================================================
#
# TODO: Updated: 2019-07-20
#
# Applying the HP / HPE PowerShell Scripting Toolkit
#
# by: Matt Muras
#
# Part 1 - Nuts and Bolts and Accessing HPE iLO
#
#=======================================================

# 1. Load HP Modules:

    Get-Module *HP* -ListAvailable | where { !($_.Name -match 'Php') } | ft -Property ModuleType,Version,Name

    $HP_Modules = (Get-Module *HP* -ListAvailable | where { !($_.Name -match 'Php') })

    $HP_Modules.Length

    $HP_Modules | ForEach-Object { Import-Module $_.Name }

#=======================================================


Get-Command *HP* | where { $_.Source -match 'EVERI_HP' }

<#

PS C:\Users\matthew.muras\Documents\github\mmuras-vmse.github.io> Get-Command *HP* | where { $_.Source -match 'EVERI_HP' }

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        AddTo-HPLegacyBootOrder                            1.1.3      EVERI_HPServer
Function        Compare-HPEServerBiosContent                       1.1.3      EVERI_HPServer
Function        Get-HPBootModeHashTable                            1.1.3      EVERI_HPServer
Function        Get-HPBootOrderHashTable                           1.1.3      EVERI_HPServer
Function        Get-HPCurrentBootMode                              1.1.3      EVERI_HPServer
Function        Get-HPCurrentBootOrder                             1.1.3      EVERI_HPServer
Function        Get-HPiLONic                                       1.1.3      EVERI_HPServer
Function        Get-HPiLONicHash                                   1.1.3      EVERI_HPServer
Function        Get-HPPendingBootMode                              1.1.3      EVERI_HPServer
Function        Get-HPServerBiosContent                            1.1.3      EVERI_HPServer
Function        Get-HPServerPowerState                             1.1.3      EVERI_HPServer
Function        Get-MyHPEBiosEntryHash                             1.1.3      EVERI_HPServer
Function        Invoke-HPBootOrderConfig                           1.1.3      EVERI_HPServer
Function        PowerOff-HPServer                                  1.1.3      EVERI_HPServer
Function        PowerOn-HPServer                                   1.1.3      EVERI_HPServer
Function        Set-HPBootOrderFirstDevice                         1.1.3      EVERI_HPServer
Function        Set-HPPendingBootMode                              1.1.3      EVERI_HPServer
Function        Update-HPEBIOSAdminPassword                        1.1.3      EVERI_HPServer
Function        Validate-HPBootModeHashTable                       1.1.3      EVERI_HPServer


#>

Get-Command *HP* | where { $_.Source -match 'Tech' }

<#

PS C:\Users\matthew.muras\Documents\github\mmuras-vmse.github.io> Get-Command *HP* | where { $_.Source -match 'Tech' }

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Get-HPSetting                                      1.0.0      TechThoughts_HPServer
Function        New-HpSession                                      1.0.0      TechThoughts_HPServer
Function        Remove-HpSession                                   1.0.0      TechThoughts_HPServer
Function        Set-HpBiosJson                                     1.0.0      TechThoughts_HPServer
Function        Set-HPBIOSSettings                                 1.0.0      TechThoughts_HPServer
Function        Test-HPRestCall                                    1.0.0      TechThoughts_HPServer

#>

#=======================================================

# 2. Setup the ILOs so we can start working with them in PowerShell

# 2.a. Find Available ILOs that have IPs like x.y.z

    $Find_ILOs = Find-HPiLO "10.10.224"


    $Find_ILOs



# 2.b. Select one of the 1 (or more) ILOs listed

    $ILO = ($Find_ILOs | where { $_.IP -match '101'})

    # $ILO = ($Find_ILOs | where { $_.IP -match '90'})

    $ILO_IP = $ILO.IP

    $ILO_IP

    # Lets go ahead and open the URL for this in Chrome

    [string]$ILO_URL = "chrome-extension://hehijbfgiekmjfkfjpbkbammjbdenadd/nhc.htm#url=https://" + "$ILO_IP"

    $ILO_URL

    start-process Chrome.exe $ILO_URL

# 3.a. Setup Variables for IP and Credential of HP and HPE Servers

    $ILO_User = 'Administrator'
    $ILO_UserPassword = 'S0m3_P@55W0rd1' # Blank it out now

    $HPiLO_Credential = Get-Credential -UserName $ILO_User -Message 'HP iLO Username and Password'


# 3.b. Special Hash Table variables: Combines IP / Server and Credential for actual HP Scripts


    $HPiLO_Server_Credential = @{

        Server     = $ILO_IP
        Credential = $HPiLO_Credential
    }

    $HPEiLO_Server_Credential = @{

        IP         = $ILO_IP
        Credential = $HPiLO_Credential
    }

<#

    ** Extra - in line - Disclaimer **

    I have to again stop here and say I do not claim what I am doing is best practice.  What I am doing allows
    me to take advantage of enough features to consistently configure my HPE servers.
#>

# 4. Quick Credential Validation Test... for 2 things:

## i.  Do I have correct credentials?

## ii. Can I connect to this ILO?

# 4.a.  Verify credentials

    get-command Get-HPServerPowerState

    Get-HPServerPowerState @HPiLO_Server_Credential

# 4.b. Testing Power Off the server with ILO

    $HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

    $HPServerPowerState

    PowerOff-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false

# 4.c. Testing Power On the server with ILO

    $HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

    $HPServerPowerState

    PowerOn-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false

<# Typically when using more advanced features to make BIOS Changes, you will want the HPE Server powered off until you are ready to commit those changes to the server BIOS.
#>

#  Connection Error Messages:

<#

If you try to run the following command:

    Get-HPServerPowerState @HPiLO_Server_Credential

And you get back this stuff, that is a good indication that you have some kind of connection problem to the iLO

    Get-ErrorDetail : Error - 10.10.224.190 -  - Retrieving information from iLO.
    Exception calling "UploadString" with "3" argument(s): "The underlying connection was closed: The connection was closed unexpectedly."
    At C:\Program Files\Hewlett-Packard\PowerShell\Modules\HPiLOCmdlets\HPiLOCmdlets.psm1:15129 char:25
    +                         throw $retobject.err
    +                         ~~~~~~~~~~~~~~~~~~~~
	    +CategoryInfo          :OperationStopped: (Exception calli...unexpectedly."
    :String) [], RuntimeException
	    +FullyQualifiedErrorId :Exception calling "UploadString" with "3" argument(s): "The underlying connection was closed: The connection was closed unexpectedly."
    At C:\Program Files\Hewlett-Packard\PowerShell\Modules\HPiLOCmdlets\HPiLOCmdlets.psm1:15223 char:17
    +                 Get-ErrorDetail $ErrorMsg
    +                 ~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
        + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Get-ErrorDetail


#>


#=======================================================

# PART 2 - HP / HPE BIOS Basics

    # code .\Part2-HP-Bios-Basics-and-beyond.ps1

    code .\Part2-HPE-Bios-Basics-and-beyond.ps1

    # ise .\Part2-HPE.ps1