function Show-PlatformHeader {
    Clear-Host
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "     PowerShell Multi-Agent Platform (Interactive UI)    " -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "Available Agents: [SystemInfoAgent, TaskAgent, HttpAgent]" -ForegroundColor DarkGray
    Write-Host "Type 'exit' or 'quit' to close the session.`n" -ForegroundColor DarkGray
}

function Show-AgentResponseView {
    param (
        [string]$AgentName,
        [string]$JsonResult
    )

    Write-Host "`n----------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host " [Response from: $AgentName]" -ForegroundColor Green
    Write-Host "----------------------------------------------------------" -ForegroundColor DarkGray
    # यहाँ LightYellow बदलकर Yellow कर दिया गया है
    Write-Host $JsonResult -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------`n" -ForegroundColor DarkGray
}

function Start-InteractiveSession {
    Show-PlatformHeader

    while ($true) {
        $query = Read-Host "Agent-CLI>"

        if ($query -eq "exit" -or $query -eq "quit") {
            Write-Host "`nClosing session. Goodbye!" -ForegroundColor Red
            break
        }

        if ([string]::IsNullOrWhiteSpace($query)) {
            continue
        }

        $rawResult = Execute-AgentWorkflow -UserQuery $query
        
        if ($rawResult) {
            Show-AgentResponseView -AgentName $rawResult.Agent -JsonResult $rawResult.DataJson
        }
    }
}