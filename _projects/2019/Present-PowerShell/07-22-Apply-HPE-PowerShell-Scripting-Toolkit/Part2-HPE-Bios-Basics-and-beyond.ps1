###========================================================
#
# TODO: Updated: 2019-07-20
#
# Applying the HP / HPE PowerShell Scripting Toolkit
#
# by: Matt Muras
#
# Part 2 - HP - BIOS Basics and a look Beyond
#
#=======================================================


# 1. Starting BIOS Session of the HP Server iLO

# 1.a. First we disconnect any open HP BIOS Sessions

    Disconnect-HPEBIOS -Connection $HPEBiosSession

    <#

    Possible Error: when Removing HP Session

    ...This error is fine to see.  It just means you dont have any session defined in your variable.


    Remove-HpSession : Cannot bind argument to parameter 'Session' because it is null.
    At line:1 char:18
    + Remove-HpSession $HPSession
    +                  ~~~~~~~~~~
        + CategoryInfo          : InvalidData: (:) [Remove-HpSession], ParameterBindingValidationException
        + FullyQualifiedErrorId : ParameterArgumentValidationErrorNullNotAllowed,Remove-HpSession

    #>

# 1.b. Build New HPESession to modify BIOS

    Get-Help Connect-HPEBIOS

    Get-Help Get-HPEBIOSSetting

     Disconnect-HPEBIOS -Connection $HPEBiosSession

    # $HPEBiosSession = Connect-HPEBIOS @HPEiLO_Server_Credential -DisableCertificateAuthentication

    $HPEBiosSession = Connect-HPEBIOS @HPEiLO_Server_Credential -DisableCertificateAuthentication

    $HPEBIOSSetting = Get-HPEBIOSSetting -Connection $HPEBiosSession

    <#

        Small Error / Warning about Secure Connection, so we force non-secure by simply repeating the command

     The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel.

     #>

# 2. Test the BIOS Hash



    $HPEBIOSSettingHash = $HPEBIOSSetting.CurrentBIOSSettings


    $HPEBIOSSettingHash



# 3. Exporting BIOS Hash as a Json

    $HPEBIOSSettingHash_Json = ConvertTo-Json $HPEBIOSSettingHash

    $HPEBIOSSettingHash_Json

    $path = 'C:\Presentation\2019\2019-07\Applying-HPE-PowerShell-Toolkit\Json\'

    $TestBios_File = 'HPE-TestBios-2019-07-21.json'

    $HPEBIOSSettingHash_Json | Out-File ($path + $TestBios_File) -Encoding ascii

    $HPEBIOSSettingHash_Json

    #  COOL TRICK! # with  parens^^^ and '+' symbol I found would work specifically with "Out-File" cmdlet when building this presentation

    Start-Process explorer $path



# 4. Importing BIOS Hash

    # 4.a. Set the path to pull files from

    $path = 'C:\Presentation\2019\2019-07\Applying-HPE-PowerShell-Toolkit\Json\' # Need to change to relative path or network path


    # 4.b. Import vNext HPE DL360 G9 BIOS

    $vNextBiosJsonFile = 'HPE-DL360-G9_BIOS_vNext_2018-05-30.json'

    $vNextBiosHash = (Get-ChildItem $path $vNextBiosJsonFile | Get-Content -raw | ConvertFrom-Json)

    $vNextBiosHash

    # 4.b. Import Special BIOS file for Reseting to Manufacturing Sesttings

    $MfgResetBiosJsonFile = 'HPE-DL360-G9_BIOS_Reset-to-MFG-settings_2018-05-28.json'

    $MfgResetBiosHash = (Get-ChildItem $path $MfgResetBiosJsonFile | Get-Content -raw | ConvertFrom-Json)

    $MfgResetBiosHash

# 5. Restore Manufacturing Defaults

    # 5.a. Action of Restore Manufacturing Defaults


    $HPEBiosSession = Connect-HPEBIOS @HPEiLO_Server_Credential -DisableCertificateAuthentication

    # Command for HPE Bios 2.55 and up

    Reset-HPEBIOSDefaultManufacturingSetting -Connection $HPEBiosSession -ResetDefaultManufacturingSetting



    # 5.b. Power Off the server with ILO - Prep setting changes

     $HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

        $HPServerPowerState

        PowerOff-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false

    # 5.c. Power On the server with ILO - Kick-off setting changes (in this case "Restore Manufacturing Defaults")

        $HPServerPowerState = Get-HPServerPowerState @HPiLO_Server_Credential

        $HPServerPowerState

        PowerOn-HPServer @HPiLO_Server_Credential -HPiLOHostPower $HPServerPowerState -Confirm:$false


# 6. Preparing for more BIOS Changes

# 6.a. Remove HP Session

    Disconnect-HPEBIOS -Connection $HPEBiosSession

# 6.b. Create New HP Session

$HPEBiosSession = Connect-HPEBIOS @HPEiLO_Server_Credential -DisableCertificateAuthentication

    # $HPSession = New-HpSession -ip $ILO_IP -username $ILO_User -password $ILO_UserPassword # -WarningVariable yes


# 7. Setup Array with Particular HP BIOS Settings that are important to me / you / operator

    <#
     Odd Question:
     (I asked very early on in developing these scripts.) - Is there any powerShell Command or scriot
     that will let you walk a Hash Table and add in all of items in Name Field to an array?

     #>

    # 7.a. Array Defining Key BIOS Entries that I care about.

            <#
                Moreover, in the list of the different BIOS settings
                we saw earlier, there are very specific entries where I
                want to see changes (it might be more, if I am not
                coming in with a newly minted / reset BIOS.

            #>

    $KeyHPEBiosEntries = @("BootMode", "ResetDefaultManufacturingSetting", "PowerProfile", "ServerPrimaryOs", "ServerOtherInfo")

    # $KeyBiosEntries = @("BootMode","RestoreManufacturingDefaults","PowerProfile","ServerPrimaryOs","ServiceName")


     # 7.b. Run Function to gather Key Bios Entries Hash

    $HPEBiosEntryHash = Get-MyHPEBiosEntryHash -HPEBiosHash $MfgResetHPEBiosHash -MyKeyBiosEntries $KeyHPEBiosEntries


    $HPEBiosEntryHash.BootMode

    $HPEPendingBiosSettingHash.ResetDefaultManufacturingSetting

    # 8. Compare current BIOS settings with settings from the $MfgResetBiosHash

        <#

            Side Note about my HP / HPE scripts

            In my newer HPE Scripts, I have turned this whole section below into a fuction
            to eliminate someone from messing up the code in some obscure place.

            My newer HPE function has a few logic differences, but it is effectively doing
            the same kind of checks to make sure that

        #>



        # Lets Run the compare code

            # TODO: Side Note, when I was working on the presentation this module kept failing to run correctly.
            # ?    I could not figure out why until I started a deep dive on that particular function.
            # ?    It turns out I had named the function file something different than "Compare-HPEServerBiosContent"

            # !--WARNING--! Do Not forget to go back and rename your files if the function name contained in that file is different

            # ? It took me nearly rebuilding the module to realize that the

# Do not run the demo of this Function - wait for the Demo section

Compare-HPEServerBiosContent -IP $ILO_IP -User $ILO_User -Password $ILO_UserPassword -HPEServerBiosContentHash $HPEBiosEntryHash -KeyBiosEntries $KeyHPEBiosEntries -TryCount 10 -Verbose

$ModulePath = "C:\Program Files\WindowsPowerShell\Modules\EVERI_HPServer\1.1.3\Public-Functions\"

    Set-Location $ModulePath

    code .\Compare-HPEServerBiosContent.ps1


 # See the newer HPE function I am working on --> ise "C:\Users\matthew.muras\Documents\WindowsPowerShell\Modules\EVERI_HPServer\1.1.0\Public-Functions\Compare-HPEBiosSettings.ps1"

 #=======================================================

## PART 3 - HP / HPE - BootMode and BootOrder

Set-Location "C:\Presentation\2019\2019-07\Applying-HPE-PowerShell-Toolkit"

    code .\Part3-HPE-BootMode-and-BootOrder.ps1