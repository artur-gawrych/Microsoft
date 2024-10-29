# Create Groups in Bulk

Connect-MgGraph -Scopes "User.Read.All", "GroupMember.ReadWrite.All", "Group.ReadWrite.All"

for ($i = 114; $i -le 130; $i++){

    $params =@{
        DisplayName     = "SG-CA$i-ExcludedUsers"
        MailNickname    = "SG-CA$i-ExcludedUsers"
        SecurityEnabled = $true
        MailEnabled     = $false
        Description     = "Users in this group are excluded from Conditional Access policy number CA$i"

    }

    New-MgGroup @params
}

for ($i = 201; $i -le 205; $i++){

    $params =@{
        DisplayName     = "SG-CA$i-ExcludedUsers"
        MailNickname    = "SG-CA$i-ExcludedUsers"
        SecurityEnabled = $true
        MailEnabled     = $false
        Description     = "Users in this group are excluded from Conditional Access policy number CA$i"

    }

    New-MgGroup @params
}


