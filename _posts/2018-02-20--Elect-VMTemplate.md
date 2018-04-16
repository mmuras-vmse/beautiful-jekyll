---
layout: post
title: Elect-VMTemplate
subtitle: a PowerCLI function for selecting a VM from multiple VMs
date: 2018-02-20
---

My environment has been subject to some complexity creep. We have multiple people building / deploying production or proudction-like VMs from templates.  In my efforts to get closer to the One Deployment tool for all environments (Dev, QA, Production, etc.), I had to overcome a challenge.  The challenge was that sometimes my templates did not deploy correctly.  This happened to be because there were already several VMs (we were treating as Templates) with the same name in different VMHost Clusters.  

We have rather large "Mixed" vCenter environment.  The environment contains hooks to Dev, QA, and Production (and other environments).  Several of my teammates use a more restricted code base for deployment of VMs so the VMs only get created on the "Dev / QA" cluster.  In my tweaking of the scripts to make them more unified, I hit the "Duplicate Object" / "Object Already Exists" error and it was bombing out my automated VM deployments.

Here is the [Elect-VMTemplate](https://mmuras-vmse.github.io/_PS1-code/2018/Elect-VMTemplate.ps1) 



    #----VMware / PowerCLI Function to Select the best VM as a template
    
        Function Elect-VMTemplate {
        <#
        .SYNOPSIS
        Selects a VM template to use.  If multiple copies (with same name) exist in vCenter then, the VM on the VMHost is used.
    
        .EXAMPLE
        $ElectVMTemplate = Elect-VMTemplate -VMTemplate $VMTemplate -VMHost $VMHost

        .EXAMPLE
        $ElectVMTemplate = Elect-VMTemplate -VMTemplate $VMTemplate -VMHost $VMHost -Rename:$true
    
        .NOTES

        #>
        [cmdletbinding()]
        param (
            # Parameter help description
            $VMTemplate,
            $VMHost,
            $Rename = $false
        )
    
        $VM_Host = Get-VMHost $VMHost

        $VMHost_prefix = $VM_Host.Name
        $VMHost_prefix = $VMHost_prefix.Split(".", 2)[0]
        $VMHost_prefix = $VMHost_prefix.Split("-", 2)[0]
        #$VMHost_prefix


        $VM_Template = Get-VM $VMTemplate | where { $_.VMHost -match $VMHost_prefix }
        #$VM_Template | Format-Table -Property Name, PowerState, NumCpu, MemoryGB, VMHost
    

        $VM_Template_NewName = $VM_Template.name + "-" + $VMHost_prefix
        if (!($VM_Template[1])) {
            #$VM_Template_NewName = $VM_Template.name + "-" + $VMHost_prefix
            $VM_Return = $VM_Template
        }
        else {
            #Write-Warning "Multiple VMs found with Name $VM_Template"
            $VM_Return = $VM_Template[0]
        }
        if ($Rename -eq $true) {
            Set-VM -VM $VM_Return -Name $VM_Template_NewName -Confirm:$false
            $VM_Return = Get-VM $VM_Template_NewName
        }
        return($VM_Return)
    }
    #---End of Function
    
![alt text](test.png)

test this
