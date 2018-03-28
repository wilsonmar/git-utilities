[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

   $SECRETS = Get-Content "$home/.secrets" | ConvertFrom-StringData
$GITHUB_USER="wilsonmar"
# $GITHUB_TOKEN="wilsonmar


# $GITHUB_TOKEN is not defined before this point so code can test if
# one needs to be created:
If ("$GITHUB_TOKEN" -eq "") {
  echo "******** Creating Auth GITHUB_TOKEN to delete repo later : "
   # Based on http://douglastarr.com/using-powershell-3-invoke-restmethod-with-basic-authentication-and-json

   $secpasswd = ConvertTo-SecureString $GITHUB_USER -AsPlainText -Force
   $cred = New-Object System.Management.Automation.PSCredential ($SECRETS.GITHUB_PASSWORD, $secpasswd)
      # CAUTION: which sends passwords through the internet here.
      # You may instead manually obtain a token on GitHub.com.

  #$Body_JSON = '{"scopes":["delete_repo"],"note":"token with delete repo scope"}'
   $BODY_JSON = "{""scopes"":[""delete_repo""], ""note"":""token with delete repo scope""}"
       echo "Body_JSON=$Body_JSON"  # DEBUGGING

   $response = Invoke-RestMethod -Method Post `
     -Credential $cred `
     -Body $Body_JSON `
     -Uri "https://api.github.com/authorizations"
   $GITHUB_TOKEN = $response.Stuffs | where { $_.Name -eq "token" }
       # Do not display token secret!
       # API Token (32 character long string) is unique among all GitHub users.
       # Response: X-OAuth-Scopes: user, public_repo, repo, gist, delete_repo scope.
       # See https://developer.github.com/v3/oauth_authorizations/#create-a-new-authorization

   # WORKFLOW: Manually see API Tokens on GitHub | Account Settings | Administrative Information 
} Else {
   echo "******** Verifying Auth GITHUB_TOKEN to delete repo later : "

   $Headers = @{
      Authorization = 'Basic ' + ${GITHUB_TOKEN}
      };
      # -f is for substitution of (0).
      # See https://technet.microsoft.com/en-us/library/ee692795.aspx
      # Write-Host ("Headers="+$Headers.Authorization)

   $response = Invoke-RestMethod -Method Get `
    -Headers $Headers `
    -ContentType 'application/json' `
    -Uri https://api.github.com

   # Expect HTTP 404 Not Found if valid to avoid disclosing valid data with 401 response as RFC 2617 defines.
    $GITHUB_AVAIL = $response.Stuffs | where { $_.Name -eq "authorizations_url" }
   echo "******** authorizations_url=$GITHUB_AVAIL.Substring(0,8)"  # DEBUGGING
}
