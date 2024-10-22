function Export-MailboxStatistics {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$CSVPath
    )

    begin {
        if (!(Test-Path $CSVPath)) {
            Write-Host "The path you have entered: '$CSVPath' does not exist. Please enter a valid path and try again." -ForegroundColor Red
            exit
        }
    }

    process {
        try {
            Get-Mailbox -ResultSize Unlimited | 
                Where-Object { $_.UserPrincipalName -notlike 'DiscoverySearchMailbox*' } | 
                Select-Object DisplayName, UserPrincipalName, 
                @{Name = 'LastLogonTime'; Expression = { (Get-MailboxStatistics $_).LastLogonTime } }, 
                @{Name = 'Mailbox Size'; Expression = { (Get-MailboxStatistics $_).TotalItemSize } } |
                Export-Csv -Path "$CSVPath\mailbox_stats.csv" -NoTypeInformation

            Write-Host "CSV exported to $CSVPath\mailbox_stats.csv" -ForegroundColor Green
        } catch {
            Write-Error "An error occurred while exporting the mailbox statistics: $_"
        }
    }

    end {
        Write-Host "Mailbox statistics export completed." -ForegroundColor Yellow
    }
}