function Invoke-TaskAgent {
    param ($State)

    Write-StructuredLog -Level "INFO" -Message "[TaskAgent] Executing File Management Task..."

    try {
        $targetDir = Join-Path $PSScriptRoot "AgentWorkspace"
        if (-not (Test-Path $targetDir)) {
            New-Item -Path $targetDir -ItemType Directory | Out-Null
        }

        $sampleFile = Join-Path $targetDir "TaskOutput.txt"
        "Agent Task Executed at $(Get-Date)" | Set-Content -Path $sampleFile

        $files = Get-ChildItem -Path $targetDir | Select-Object Name, Length, LastWriteTime

        $data = @{
            WorkspacePath = $targetDir
            FilesFound    = $files
        }

        return [AgentResponse]::new("TaskAgent", $true, $data, "")
    }
    catch {
        return [AgentResponse]::new("TaskAgent", $false, @{}, $_.Exception.Message)
    }
}