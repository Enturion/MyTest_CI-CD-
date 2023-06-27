Set-ExecutionPolicy unrestricted 

#.\ALC\alc.exe /project:. /out:.\Olister.app /packagecachepath:.\AlPackages

ls

#########################
# PowerShell example
#########################
$ClientID     = "51cb560d-1398-43e8-a7bf-fa7fe3e35102"
$ClientSecret = "~Xk8Q~Uho6Jz3MmdMbX5rlQWnyRu4IflZ_vsZdol"
$loginURL     = "https://login.microsoftonline.com"
$tenantId     = "763b2d72-dcd0-44c9-b236-7f57e4eb7c51"
$scopes       = "https://api.businesscentral.dynamics.com/.default"
$companyId      = "ab80bd8d-339d-eb11-8ce5-000d3a21fbdf"
$environment  = "DEV"
$baseUrl      = "https://api.businesscentral.dynamics.com/v2.0/"+$tenantId+"/"+$environment+"/api/v2.0/companies("+$companyId+")/extensionUpload(0)/content"

#Prepare token request
$authUrl = 'https://login.microsoftonline.com/' + $tenantId + '/oauth2/v2.0/token'

$baseUrl      = "https://api.businesscentral.dynamics.com/v2.0/$environment/api/microsoft/automation/v1.0"
$appFile =  (Get-Item (".\Olister.app")).FullName
# Get access token 
$body = @{grant_type="client_credentials";scope=$scopes;client_id=$ClientID;client_secret=$ClientSecret}
$oauth = Invoke-RestMethod -Method Post -Uri $("$loginURL/$tenantId/oauth2/v2.0/token") -Body $body
# Get companies
$companies = Invoke-RestMethod `
             -Method Get `
             -Uri $("$baseurl/companies") `
             -Headers @{Authorization='Bearer ' + $oauth.access_token}
$companies.value | Format-Table -AutoSize
$companyId = $companies.value[1].id
# Upload and install app
Invoke-RestMethod `
-Method Patch `
-Uri $("$baseurl/companies($companyId)/extensionUpload(0)/content") `
-Headers @{Authorization='Bearer ' + $oauth.access_token;'If-Match'='*'} `
-ContentType "application/octet-stream" `
-InFile $appFile

Start-Sleep -s 10