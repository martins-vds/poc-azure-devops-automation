using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

Import-Module 'AzDevOps'

$organization = $Request.Body.Organization
$project = $Request.Body.Project

if (-not $organization -or -not $project) {
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = "Please pass an organization and project in the request body."
    })

    return
}

try{
    $projectDetails = Get-Project -Organization $organization -Project $project

    if ($null -eq $projectDetails) {
        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::NotFound
            Body = "Project '$project' not found."
        })

        return
    }

    $projectDescriptor = Get-ProjectDescriptor `
                            -Organization $organization `
                            -StorageKey $projectDetails.id

    $projectGroups = Get-ProjectGroups `
                        -Organization $organization `
                        -ProjectScopeDescriptor $projectDescriptor

    $projectValidUsersGroup = $projectGroups | Where-Object { $_.displayName -eq "Project Valid Users" }

    Write-Host "Denying project creation permissions for $($projectValidUsersGroup.principalName)"

    $projectValidUsersGroupIdentity = Get-Identity `
                                        -Organization $organization `
                                        -SubjectDescriptor $projectValidUsersGroup.descriptor

    $gitRepositorySecurityNamespace = Get-SecurityNamespace `
                                        -Organization $organization `
                                        -Namespace "Git Repositories"

    $createRepositoryPermission = $gitRepositorySecurityNamespace.actions `
                                | Where-Object { $_.name -eq "CreateRepository" } `
                                | Select-Object -First 1

    Update-AccessControlEntries -Organization $organization `
                                -NamespaceId $gitRepositorySecurityNamespace.namespaceId `
                                -Token "repoV2/$($projectDetails.id)" `
                                -Descriptor $projectValidUsersGroupIdentity.descriptor `
                                -PermissionBit $createRepositoryPermission.bit `
                                -Deny
    # Associate values to output bindings by calling 'Push-OutputBinding'.
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::Created
    })                        
}
catch [Microsoft.PowerShell.Commands.HttpResponseException]{
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $_.Exception.Response.StatusCode
        Body = $_.Exception.ToString()
    })
}catch{
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::InternalServerError
        Body = $_.Exception.ToString()
    })
}


