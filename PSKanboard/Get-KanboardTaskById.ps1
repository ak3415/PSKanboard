<#
.Synopsis
View details about a task on the Kanboard

.Parameter TaskId
ID of the task to look up

.Link 
api_docs: https://kanboard.net/documentation/api-json-rpc

.Link
homepage: https://github.com/soulruins/PSKanboard 
#>
function Get-KanboardTaskById {
    [CmdletBinding()]
    Param (
    [Parameter (Mandatory=$True, Position=1, ValueFromPipeline=$True)]
    $TaskId
    )
    ##
    begin { }
    process { }
    end {
    . $PSScriptRoot\pskanboard-conf.ps1
    ##
    $secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ($user, $secpasswd)
    ##
    $Json = @{
        jsonrpc = "2.0"
        method = "getTask"
        id = "1"
        params = @{
            "task_id" = $TaskId
        }
    }
    $Json = $Json | ConvertTo-Json
    $Res = Invoke-RestMethod -Method Post -Uri $uri -Credential $cred -Body $Json -ContentType 'application/json'
    $Res.result = $Res.result | ForEach-Object {
            $_.date_creation = if ($_.date_creation -gt 0) { [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($_.date_creation)) } else { "0" }
            $_.date_due = if ($_.date_due -gt 0) { [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($_.date_due)) } else { "0" }
            $_.date_modification = if ($_.date_modification -gt 0) { [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($_.date_modification)) } else { "0" }
            $_.date_moved = if ($_.date_moved -gt 0) { [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($_.date_moved)) } else { "0" }
            $_.date_completed = if ($_.date_completed) { [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($_.date_completed)) }
            $_
            }
    $Res.result
    }
}