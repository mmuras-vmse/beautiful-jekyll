Function Elect-VMTemplate {
    <#
    .SYNOPSIS
    Selects a VM template to use.  If multiple copies exist in vCente then, one on the VMHost is used.
    
    .EXAMPLE
    Elect-VMTemplate -VMTemplate $VMTemplate -VMHost $VMHost

    .EXAMPLE
    Elect-VMTemplate -VMTemplate $VMTemplate -VMHost $VMHost -Rename:$true
    
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
