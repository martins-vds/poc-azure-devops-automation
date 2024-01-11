using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

function Get-ErrorMessage {
    param([string]$ErrorString)

    if ([string]::IsNullOrEmpty($ErrorString)) {
        return ""
    }

    $errorObject = ConvertFrom-Json $ErrorString -Depth 10

    $messageProperty = $errorObject | Get-Member -MemberType NoteProperty | Where-Object { $_.Name -eq "Message" } | Select-Object -First 1

    if ($null -eq $messageProperty) {
        return ""
    }

    return $errorObject.$($messageProperty.Name)
}

Import-Module 'AzDevOps'

$organization = $Request.Body.Organization
$project = $Request.Body.Project
$processTemplateId = $Request.Body.ProcessTemplateId

if (-not $organization -or -not $project -or -not $processTemplateId) {
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = "Please pass an organization, project and process template id in the request body."
    })

    return
}

try {
    $newProject = New-Project -Organization "$organization" -ProjectName "$project" -ProcessTemplateId "$processTemplateId"

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::Created
        Body = $newProject
        ContentType = "application/json"
    })
}
catch [Microsoft.PowerShell.Commands.HttpResponseException]{
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $_.Exception.Response.StatusCode
        Body = Get-ErrorMessage -ErrorString $_.ErrorDetails.Message
    })
}catch{
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::InternalServerError
        Body = $_.Exception.ToString()
    })
}

