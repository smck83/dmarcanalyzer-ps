$token = "<--API-TOKEN-->" # Personal Access Token, if you have account API Key and Secret you wlil need to dynamically generate the API-TOKEN via standard JWT auth
$custid = "<--CUST-ID-->"  # When you login to the web interface, the customer ID will be visible in the URL path https://app.dmarcanalyzer.com/customers/<--CUST-ID-->/home

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $token")

function getUsers(){
$users = Invoke-RestMethod https://api.dmarcanalyzer.com/customers/$custid/users -Method 'GET' -Headers $headers
$users = $users.data | select -Property id,email
write-host "Users: $($users.email)"
$output =    foreach ($user in $users){
    $response = Invoke-RestMethod https://api.dmarcanalyzer.com/customers/$custid/user/$($user.id)/domaingroups -Method 'GET' -Headers $headers
    
    foreach ($group in $($response.data.name)){

        [PSCustomObject]@{
          
          "group name" = $group
          "user" = $user.email


         }
        }

    }

return $output

}

$output = getUsers | Group-Object -Property "group name" | 
  Select-Object @{n='group name'; e={ $_.Values[0] }}, 
                @{n='user';    e={ [string]$($_.Group | Select-Object -property user).user}}

$output | Export-Csv -NoTypeInformation groupOutput.csv 
