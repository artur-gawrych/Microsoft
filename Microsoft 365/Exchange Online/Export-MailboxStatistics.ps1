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

function Export-MailboxStatistics {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$CSVFile
    )

    begin {
            Write-Log "Stating the export...."
         }

    process {
        try {
            Get-Mailbox -ResultSize Unlimited | 
                Where-Object { $_.UserPrincipalName -notlike 'DiscoverySearchMailbox*' } | 
                Select-Object DisplayName, UserPrincipalName, 
                @{Name = 'LastLogonTime'; Expression = { (Get-MailboxStatistics $_).LastLogonTime } }, 
                @{Name = 'Mailbox Size'; Expression = { (Get-MailboxStatistics $_).TotalItemSize } } |
                Export-Csv -Path $CSVFile -NoTypeInformation

            Write-Log "CSV exported to $CSVFile"
        } catch {
            Write-Log "An error occurred while exporting the mailbox statistics: $_"
        }
    }

    end {
        Write-Log "Mailbox statistics export completed."
    }
}