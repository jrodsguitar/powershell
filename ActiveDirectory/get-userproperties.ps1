$users = Get-ADUser -Filter * -Properties *

$results = @()

foreach ($user in $users) {

    $groups = $user.memberof -join ';'

    $properties = @{

        User       = $user.name
        Groups     = $groups
        FirstName  = $user.GivenName
        LastName   = $user.surname
        Email      = $user.EmailAddress
        Department = $user.Department

    }

    $results += New-Object psobject -Property $properties
}

$results