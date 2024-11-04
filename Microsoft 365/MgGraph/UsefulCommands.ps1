# Connect to MgGraph with user and group scopes

Connect-MgGraph -Scopes "User.ReadWrite.All", "GroupMember.ReadWrite.All", "Group.ReadWrite.All" -TenantID "ID HERE"

# Remove ImmutableID

Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/Users/{UserId}" -Body @{OnPremisesImmutableId = $null}

