<#
.Synopsis
Move a Kanboard task to a different position

.Parameter ProjectId
Project ID 

.Parameter TaskId
ID of the task that will be moved. 

.Parameter ColumnPosition
The column position on the project board that the task should be moved to. Left most column position is 1. 
The column_id will be automatically calculated based on the column position suplied.

.Parameter Position
New vertical position for the task in the selected ColumnPosition. 

.Parameter SwimlaneId
ID number of new Swimlane for the task. 
Swimlane IDs are counted started from 0. 

.Parameter Force
Move the task without confirming action. 

.Link 
api_docs: https://kanboard.net/documentation/api-json-rpc

.Link
homepage: https://github.com/soulruins/PSKanboard 
#>function Move-KanboardTask {
    [CmdletBinding()]
    Param (
    [Parameter (Mandatory=$True, Position=1, ValueFromPipeline=$True)]
    [int]$ProjectId,
    [Parameter (Mandatory=$True, Position=2)]
    [int]$TaskId,
    [Parameter (Mandatory=$True, Position=3)]
    [int]$ColumnPosition,
    [Parameter (Mandatory=$True, Position=4)]
    [int]$Position,
    [Parameter (Mandatory=$False, Position=5)]
    $SwimlaneId,
    [Parameter (Mandatory=$False)]
    [switch] $Force
    )
    ##
    begin { 
        if($SwimlaneId -ne $Null) { 
            Try { 
                $IsInt = [int]$SwimlaneId
            } Catch {
                Write-Host 'SwimlaneId provided was not an integer. Swimlane IDs are counted started from 0.'
                Break All 
            }
        }
    }
    process { }
    end {
    # Setup credentials
    . $PSScriptRoot\pskanboard-conf.ps1
    $secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ($user, $secpasswd)

    # Confirm Action
    if($Force){
        # If Force flag is chosen, proceed with moving the task without confirming
    } else {
        # Get current task info
        $TaskToMove = Get-KanboardTaskById $TaskId
        
        # Prompt user
        $Title = 'Are you sure you want to perform this action?'
        $Prompt = 'This action will move task ' + $TaskId + ' [' + ($TaskToMove).title + '] to column ' + $ColumnPosition + '.'
        $Yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Move the Task'
        $No = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Abort action without moving task'
        $Options = [System.Management.Automation.Host.ChoiceDescription[]] ($Yes, $No)
        $Choice = $Host.ui.PromptForChoice($Title,$Prompt,$Options,0)

        # Abort program if user does not confirm action
        if($Choice -eq 1) { 
            Write-Host 'No changes made'
            Break All
        }
    }

    # Move Task
    $Json = @{
        jsonrpc = "2.0"
        method = "moveTaskPosition"
        id = "1"
        params = @{
            "project_id" = $ProjectId
            "task_id" = $TaskId
            "column_id" = (Get-KanboardColumn $ProjectId | ? {$_.position -eq $ColumnPosition}).id
            "position" = $Position
            "swimlane_id" = 
                if($SwimlaneId -eq $Null){ 
                    if(!$TaskToMove) { $TaskToMove = Get-KanboardTaskById $TaskId }
                    ($TaskToMove).swimlane_id 
                } else { 
                    $SwimlaneId 
                }
        }
    }
    $Json = $Json | ConvertTo-Json
    ##
#    $Res = Invoke-RestMethod -Method Post -Uri $uri -Credential $cred -Body $Json -ContentType 'application/json'
#    if($Res.result -ne 'True') { Write-Output 'Could not move the task. Response from server: ' $Res.result }
    }
}