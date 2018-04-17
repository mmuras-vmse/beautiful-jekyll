---
layout: post
title: Invoke-SshCiscoCommand
subtitle: a PowerShell function for sending Cisco syntax to a Cisco device
date: 2018-04-16
---

In my environment we have had some serious changes that are getting a little bit hard to keep track of.  We have had quite a bit of 
Cisco gear getting moved around and new gear getting added.

Notably, our SVI (Layer 3 Vlan interfaces) sit 3 layer 2 hops away from our VMHosts which are on a Ten Gig Cisco VSS.  

Also we use "switchport trunk allowed vlan" commands to force users to manually add vlans to ports.  The intention is that it takes
a "human" or some kind of knowable action to make this change.

For those that know Cisco, VTP can be a good thing and it can also be a VERY BAD thing.  Some of the negative consequences of VTP 
are what drove my team to disable VTP as a whole in our Development / QA networks on premise.   

The biggest immediate and visible setback with these conditions being true is we had to spend 5 to 10 minutes just changing / updating
the list of 10+ different interfaces between the 3 core devices.  Thats not including having to update this on edge or other places.

I played with Putty and Plink.exe before and just dabbled in Posh-SSH.  This is my first real journey into the Posh-SSH world.

NOTE: For more info on Posh-SSH, see link to [PowerShell Gallery - Possh-SSH](https://www.powershellgallery.com/packages/Posh-SSH/2.0.2)

WARNING 1: To be fair, I may have made some security adjustments to this script which are not best practice.  

WARNING 2: The script will execute any / all commands you send to the Cisco device (assuming your credentials 
and the IP Address are correct).  Moreover, this script will not do any Cisco syntax checking for you.

Here is the [Invoke-SshCiscoCommand](https://mmuras-vmse.github.io/_PS1-code/2018/Invoke-SshCiscoCommand.ps1) 

	#----PowerShell function to send Cisco commands to Cisco device
	
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




