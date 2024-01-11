function Get-Token() {
    $token = $env:ADOS_PAT

    if ([string]::IsNullOrEmpty($token))
    {
        throw "PAT Token is missing. Provide it through enviroment variable 'ADOS_PAT'"
    }

    return $token
}

function Get-AuthorizationToken {
    return "Basic $([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(":$(Get-Token)")))"
}

function BuildHeaders ($additionalHeaders = @{}) {
    $headers = @{}

    $additionalHeaders.Keys | ForEach-Object {
        $headers[$_] = $additionalHeaders[$_]
    }

    $headers.Accept = "application/json"
    $headers."Content-Type" = "application/json"
    $headers.Authorization = Get-AuthorizationToken

    return $headers
}

function Get ($uri, $additionalHeaders = @{}) {
    return Invoke-RestMethod -Uri $uri -Method Get -Headers $(BuildHeaders -additionalHeaders $additionalHeaders)
}

function Put ($uri, $body, $additionalHeaders = @{}) {
    return Invoke-RestMethod -Uri $uri -Method Put -Headers $(BuildHeaders -additionalHeaders $additionalHeaders) -Body $($body | ConvertTo-Json)
}

function Patch ($uri, $body, $additionalHeaders = @{}) {
    return Invoke-RestMethod -Uri $uri -Method Patch -Headers $(BuildHeaders -additionalHeaders $additionalHeaders) -Body $($body | ConvertTo-Json)
}

function Post ($uri, $body, $additionalHeaders = @{}) {
    return Invoke-RestMethod -Uri $uri -Method Post -Headers $(BuildHeaders -additionalHeaders $additionalHeaders) -Body $($body | ConvertTo-Json)
}

function Delete ($uri, $additionalHeaders = @{}) {
    return Invoke-RestMethod -Uri $uri -Method Delete -Headers $(BuildHeaders -additionalHeaders $additionalHeaders)
}

function Get-Operation{
    param (
        [Parameter(Mandatory = $true)]
        [string] $Organization,
        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    $uri = "https://dev.azure.com/$Organization/_apis/operations/$($Id)?api-version=7.1-preview.1"

    return Get -uri $uri
}

function Wait-Operation {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Organization,
        [Parameter(Mandatory = $true)]
        [string] $Id,
        [Parameter(Mandatory = $false)]
        [switch] $ThrowIfNotSuccess
    )

    $operation = Get-Operation -Organization $Organization -Id $Id

    while ($operation.status -eq "inProgress" -or $operation.status -eq "queued" -or $operation.status -eq "notSet") {
        Start-Sleep -Seconds 1
        $operation = Get-Operation -Organization $Organization -Id $Id
    }

    if ($ThrowIfNotSuccess -and $operation.status -ne "succeeded") {
        throw "Operation $Id did not succeed. Reason: $($operation.resultMessage)"
    }
}

function New-Project {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Organization,
        [Parameter(Mandatory = $true)]
        [string] $ProjectName,
        [Parameter(Mandatory = $true)]
        [string] $ProcessTemplateId,
        [Parameter(Mandatory = $false)]
        [string] $Description = "Created by Azure Function",
        [Parameter(Mandatory = $false)]
        [string] $Visibility = "private"        
    )

    $project = Get-Project -Organization $Organization -ProjectName $ProjectName

    if ($null -ne $project) {
        return $project
    }

    $processTemplate = Get-ProcessTemplate -Organization $Organization -Id $ProcessTemplateId

    $uri = "https://dev.azure.com/$Organization/_apis/projects?api-version=7.1-preview.4"

    $body = @{
        name = $ProjectName
        description = $Description
        visibility = $Visibility
        capabilities = @{
            versioncontrol = @{
                sourceControlType = "Git"
            }
            processTemplate = @{
                templateTypeId = $($processTemplate.id)
            }
        }
    }

    $operation = Post -uri $uri -body $body

    Wait-Operation -Organization $Organization -Id $operation.id -ThrowIfNotSuccess   

    return Get-Project -Organization $Organization -ProjectName $ProjectName
}

function Get-ProcessTemplate {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Organization,
        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    $uri = "https://dev.azure.com/$Organization/_apis/process/processes/$($Id)?api-version=7.2-preview.1"

    return Get -uri $uri
}

function Get-Project {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Organization,
        [Parameter(Mandatory = $true)]
        [string] $ProjectName
    )
    
    $uri = "https://dev.azure.com/$Organization/_apis/projects/$($ProjectName)?api-version=7.2-preview.4"    

    try {
        return Get -uri $uri
    }
    catch [Microsoft.PowerShell.Commands.HttpResponseException]{
        if ($_.Exception.Response.StatusCode -eq 404) {
            return $null
        }
        else {
            throw $_
        }
    }
}

function Get-ProjectDescriptor {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Organization,
        [Parameter(Mandatory = $true)]
        [string] $StorageKey
    )

    $uri = "https://vssps.dev.azure.com/$Organization/_apis/graph/descriptors/$($StorageKey)"

    return Get -uri $uri | Select-Object -ExpandProperty value
}

function Get-ProjectGroups {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Organization,
        [Parameter(Mandatory = $true)]
        [string] $ProjectScopeDescriptor
    )

    $uri = "https://vssps.dev.azure.com/$Organization/_apis/graph/groups?scopeDescriptor=$($ProjectScopeDescriptor)&api-version=7.1-preview.1"

    return Get -uri $uri | Select-Object -ExpandProperty value
}

function Get-Identity {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Organization,
        [Parameter(Mandatory = $true)]
        [string] $SubjectDescriptor
    )

    $uri = "https://vssps.dev.azure.com/$Organization/_apis/identities?subjectDescriptors=$($SubjectDescriptor)&queryMembership=None&api-version=7.1-preview.1"

    return Get -uri $uri | Select-Object -ExpandProperty value | Select-Object -First 1
}

function Get-SecurityNamespaces {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Organization
    )

    $uri = "https://dev.azure.com/$Organization/_apis/securitynamespaces?api-version=7.1-preview.1"

    return Get -uri $uri | Select-Object -ExpandProperty value
}

function Get-SecurityNamespace {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Organization,
        [Parameter(Mandatory = $true)]
        [string] $Namespace
    )

    return Get-SecurityNamespaces -Organization $Organization | Where-Object { $_.displayName -eq $Namespace } | Select-Object -First 1
}

function Update-AccessControlEntries {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Organization,
        [Parameter(Mandatory = $true)]
        [string] $NamespaceId,
        [Parameter(Mandatory = $true)]
        [string] $Token,
        [Parameter(Mandatory = $true)]
        [string] $Descriptor,
        [Parameter(Mandatory = $true)]
        [int] $PermissionBit,
        [Parameter(Mandatory = $false)]
        [switch]
        $Deny
    )

    $uri = "https://dev.azure.com/$Organization/_apis/accesscontrolentries/$($NamespaceId)?api-version=7.1-preview.1"

    $body = @{
        token = $Token
        merge = $true
        accessControlEntries = @(
            @{
                descriptor = $Descriptor
                allow = $($Deny ? 0 : $PermissionBit)
                deny = $($Deny ? $PermissionBit : 0)
            }
        )
    }

    Post -uri $uri -body $body | Out-Null
}

Export-ModuleMember -Function Get-Project
Export-ModuleMember -Function New-Project
Export-ModuleMember -Function Get-ProjectDescriptor
Export-ModuleMember -Function Get-ProjectGroups
Export-ModuleMember -Function Get-Identity
Export-ModuleMember -Function Get-SecurityNamespaces
Export-ModuleMember -Function Get-SecurityNamespace
Export-ModuleMember -Function Update-AccessControlEntries
