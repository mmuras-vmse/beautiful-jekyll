##========================================================
#
# TODO: Updated: 2019-07-20
#
# Origin:  2018-06-26
#
# Applying the HP / HPE PowerShell Scripting Toolkit
#
# ? Name:    Matt Muras
# ? Twitter: @vmse_mmuras
# ? Email:   mmuras@gmail.com
# ? GitHub:  mmuras-vmse.github.io
#
# About:   Network & Systems Arctiect at EVERI Games (formerly Multimedia Games).
#          Focus: Infrastructure-as-Code with applications in Hardware (HP / HPE), VMware, Cisco, and Windows
#          Working with VMware for 9 to 10 years
#          Working / scripting / writing PowerShell and PowerCLI for the last 3 years
#
##========================================================

# Set-Location "C:\Presentation\Applying-HPE-PowerShell-Toolkit"

# Set-Location "C:\Users\matthew.muras\Documents\Presentation\2019\2019-07\Applying-HPE-PowerShell-Toolkit"

Set-Location "C:\Presentation\2019\2019-07\Applying-HPE-PowerShell-Toolkit"

Start-Process ".\Get-Workflow.png"

#=======================================
<#

1. Disclaimer:

    I do not work for HP or HPE. So my application of the HP / HPE PowerShell Scripting Toolkit is
    ALMOST CERTAINLY NOT best practice.  Any code used or downloaded from this site / presentation is provided
    on an AS IS Basis and the author of the code cannot be held liable for any issues or faults the code may
    create in your environment.

    (Transaltion: ALWAYS TEST NEW CODE in a Development / Sand Box environment that is not going to harm
    your production workloads.)

    (In other words: Test your code where you won't screw stuff up!)
#>

#=======================================

# 1.a. Where do I get the HPE PowerShell Scripting Toolkit?

start-process Chrome.exe "https://www.hpe.com/us/en/product-catalog/detail/pip.scripting-tools-for-windows-powershell.5440657.html"

    <#

        # From the "...Key Features..." section

    # 1. Utilizes Proven Windows PowerShell Technology for reliable and repeatable scripting

    # 2. Reliable and Repeatable Scripting Capabilities

    # 3. Configure and Manage HPE Servers

            # HPE Servers BIOS cmdlets support both Legacy and UEFI (Unified Extensible Firmware Interface) Boot Modes on Gen9 & Gen10 systems.

            # HPE iLO 3, iLO 4 and iLO 5 PowerShell cmdlets supported including iLO Federation.
    #>





# 1.b. What scripts / functions / modules I use...

Get-Module *HP* -ListAvailable | where { !($_.Name -match 'Php') } | ft -Property ModuleType,Version,Name

    # You can find some of the newer Modules on the Gallery

    Find-Module HP*  | ft -Property ModuleType,Version,Name,Repository

<#
    Notes about these Modules:

    As you can probably guess most of these are written by HP / HPE.  However, I would like to
    GIVE CREDIT to Jake Morrison (Works for Rackspace) and maintains his blog TechThoughts.info.
    He wrote the functions I am using in Module "TechThoughts_HPServer".

    I write my HP / HPE functions in EVERI_HPServer.

    Some of the functions running on my PC from HP / HPE may be a
    little out of date.

#>

    #Tech Thoughts Blog

    start-process Chrome.exe "http://techthoughts.info/ilo-restful-api-powershell/"

<#

    Other PowerShell Scripting Tools (for other vendors / servers):

    Some or most of you probably do not use HP or HPE Servers.  I get that.  Here are a few other
    vendors that support Automation with PowerShell for their server solutions.

    NOTE: I have not speant any time researching solutins for these other vendor products as my company
    is currently HP / HPE for most rack mount servers."
    #>

    #Dell iDrac PowerShell Automation

    start-process Chrome.exe "http://en.community.dell.com/cfs-file/__key/telligent-evolution-components-attachments/13-4491-00-00-20-44-44-34/Dell-EMC-PowerEdge-Server-Management-by-using-iDRAC-REST-API.pdf?forcedownload=true"

    #Cisco PowerTool Suite

    start-process Chrome.exe "https://communities.cisco.com/docs/DOC-37154"

    # IBM IMM PowerShell Notes - Discussion

    start-process Chrome.exe "https://ps1code.com/2015/08/11/imm-module/"

    # There are probably many others too . . . But these are not the ToolKits you are looking for (today) . . . Move-Along


#=======================================

# Table of Contents:

# Set-Location "C:\Presentation\Applying-HPE-PowerShell-Toolkit"

Set-Location "C:\Presentation\2019\2019-07\Applying-HPE-PowerShell-Toolkit"

## PART 1 - Nuts and Bolts and Accessing HPE iLO

    code .\Part1-HP-HPE-ilo.ps1

## PART 2 - HP / HPE - BIOS Basics and a look beyond

    code .\Part2-HPE-Bios-Basics-and-beyond.ps1

    #ise .\Part2-HPE-Bios-Basics-and-beyond.ps1  <- For Future Presentations

## PART 3 - HP / HPE - BootMode and BootOrder

    code .\Part3-HPE-BootMode-and-BootOrder.ps1

## PART 4 - HP Demo - shows scripts discussed running together to setup a G9 Server

    code .\Part4-HPE-Demo.ps1