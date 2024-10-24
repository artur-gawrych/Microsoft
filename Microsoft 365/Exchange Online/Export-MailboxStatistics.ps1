function Export-MailboxStatistics {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$CSVFile
    )

    begin {
            Write-Output "Stating the export...."
         }

    process {
        try {
            Get-Mailbox -ResultSize Unlimited | 
                Where-Object { $_.UserPrincipalName -notlike 'DiscoverySearchMailbox*' } | 
                Select-Object DisplayName, UserPrincipalName, 
                @{Name = 'LastLogonTime'; Expression = { (Get-MailboxStatistics $_).LastLogonTime } }, 
                @{Name = 'Mailbox Size'; Expression = { (Get-MailboxStatistics $_).TotalItemSize } } |
                Export-Csv -Path $CSVFile -NoTypeInformation

            Write-Output "CSV exported to $CSVFile"
        } catch {
            Write-Error "An error occurred while exporting the mailbox statistics: $_"
        }
    }

    end {
        Write-Output "Mailbox statistics export completed."
    }
}