function Write-Log {
    [CmdletBinding()]
    param (
        [string]$Message
    )
    
    begin {
        $LogLocation = "$env:USERPROFILE\AppData\Roaming\PowerShell\Logs"
        if (!(Test-Path $LogLocation)){
            New-Item -ItemType Directory -Path $LogLocation -Force
        }
        $LogTimestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $LogFileName = "PowerShell_$(Get-Date -Format 'yyyy_MM_dd').log"
    }
    
    process {
        $LogMessage = "$LogTimestamp - $Message"
        Write-Output $LogMessage
        Add-Content -Path "$LogLocation\$LogFileName" -Value $LogMessage
    }
    
}
function Copy-Data {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Source,
        [Parameter(Mandatory)]
        [string]$Destination,
        [Parameter(Mandatory)]
        [string]$LogLocation,
        [Parameter]
        [string]$Options = "/E /ZB /copy:DAT /dcopy:DAT /R:0 /W:0 /V /",
        [Parameter]
        [string]$Logging = "/log:$("$LogLocation\$(Get-Date -f yyyy_MM_dd)_robocopy.log")"
    )
    
    begin {
        if (!(Test-path $LogLocation)){
            Write-Log "Creating log location directory - $LogLocation"
            New-Item -ItemType Directory $LogLocation -Force
        }
    }
    
    process {
        Write-Log "Staring to copy data from $Source to $Destination"
        robocopy $Source $Destination $Options $Logging
    }
    
    end {
        Write-Log "Finisshed copying data. Please see the robocopy logs for more information locaated in $LogLocation"
    }
}