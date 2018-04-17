<#
.SYNOPSIS
    Sends Cisco command or commands to a Cisco device via PowerShell
.DESCRIPTION
    Uses the Posh-SSH module to connect via SSH to a Cisco Device and execute command.
.PARAMETER IPAddress
    The Cisco device being queried or changed by the command or list of commands being sent.
.PARAMETER Credential
    This is the credentail used to login to the Cisco device.
.PARAMETER CiscoCommand
    The command or list of commands in order to send to the Cisco device.
.PARAMETER Sleep
    This is the number of seconds to wait to apply next command in list of commands from CiscoCommand parameter.
.PARAMETER LogSession
    If LogSession is set to TRUE then the final output will be copied to a file and stored 
    on the computer running the Invoke-SshCiscoCommand.
.EXAMPLE
    $CiscoCommand = "
        conf t
        vlan 405
        end
        wr mem
    "
    $CiscoOutput = Invoke-SshCiscoCommand -IPAddress $IPAddress -Credential (Get-Credential) -CiscoCommand $CiscoCommand -Sleep 5
    $CiscoOutput
.NOTES
    This command will send one line at a time to the switch and then wait X number of seconds depending on -Sleep parameter.
    Make sure cisco commands are valid as the script will not do any error handling.  Any detectable
    errors in Cisco IOS syntax will be reported by the Cisco Device directly in the output.
#>
function Invoke-SshCiscoCommand {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("ComputerName", "Name")]
        $IPAddress,
        [Parameter(Mandatory = $true,
            Position = 1)]
        [Alias("PSCredential")]
        [pscredential]$Credential,
        [Parameter(Mandatory = $true,
            Position = 2,
            ValueFromPipeline = $false
        )]
        $CiscoCommand = "show run | inc hostname",
        [Parameter(
            Position = 3,
            ValueFromPipeline = $false
        )]
        [int]$Sleep = 5,
        [Parameter(
            Position = 4,
            ValueFromPipeline = $false
        )]
        [bool]$LogSession = $true
    )

    $SshSession = New-SSHSession -ComputerName $IPAddress -Credential $Credential -AcceptKey -Force

    $sessions = Get-SSHSession
    foreach ($session in $sessions) {
        if ($session.Host -eq $IPAddress) {
            $UseSession = Get-SSHSession -SessionId $session.SessionId
            break
        }
    }


    $stream = $UseSession.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
    
    # Adds extra blank line to the beginning of the command set being sent to the Cisco Device
    $CiscoCommand = "`n $CiscoCommand"

    if ($CiscoCommand[1]) {

        $PlinkPath = "C:\Tools\Powershell\Plink"
       <# if (!(Test-Path -path $PlinkPath)) {
            New-Item -ItemType Directory -Path $PlinkPath
        }#>
        $SshCommandFile = $PlinkPath + "\" + "SshCommandFile.txt"
        $CiscoCommand | out-file -FilePath $SshCommandFile -Encoding ascii
        $CiscoCommandFile = Import-Csv -Path $SshCommandFile

        foreach ($line in $CiscoCommandFile) {
        
            [string]$new_command = $line
            $new_command = $new_command.Split("=", 2)[1]
            
            $new_command = $new_command.Split("}", 2)[0]
            
            $sessionCommand = "$new_command `n`n"
            # $sessionCommand = The Cisco Command from $command + the [Enter] key
            $stream.Write($sessionCommand)
        }
    }
    Start-Sleep -Seconds $Sleep
    $SshSessionOutput = $stream.Read()

    
    Remove-Item -Path $SshCommandFile
    # Clean up SSHSession after running commands
    Remove-SSHSession -SessionId $session.SessionId
    if ($LogSession -eq $true) {
        $Date = Get-date 

        function Format-DateYMD {

            param($date)

            $yyyy = [string]$date.Year
            $mm_month = [string]$date.Month
            $dd_date = [string]$date.Day

            if ($mm_month.Length -lt 2) { $mm_month = '0' + $mm_month }
            if ($dd_date.Length -lt 2) { $dd_date = '0' + $dd_date }

            [string]$yyyy_mm_dd = $yyyy + "-" + $mm_month + "-" + $dd_date
            # End get date YYYY-MM-DD
        
            return($yyyy_mm_dd)

        }
        
        $FomatDate = Format-DateYMD -date $date

        $Hour = $date.Hour
        $Minute = $date.Minute
        $Second = $date.Second
        
        $LogDate = $FomatDate + "--" + $date.Hour + "." + $date.Minute + "." + $date.Second

        $SessionLog = $PlinkPath + "\" + $IPAddress + "_" + $LogDate + ".log"
        $SshSessionOutput | Out-File -FilePath $SessionLog
    }
    return($SshSessionOutput)
}