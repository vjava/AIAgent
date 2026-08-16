function Load-EnvFile {
    param ([string]$EnvPath = "$PSScriptRoot\.env")

    if (Test-Path $EnvPath) {
        Get-Content $EnvPath | ForEach-Object {
            $line = $_.Trim()
            # खाली लाइनों और कमेंट्स (#) को छोड़ें
            if ($line -and -not ($line.StartsWith("#"))) {
                $key, $value = $line -split '=', 2
                if ($key -and $value) {
                    [System.Environment]::SetEnvironmentVariable($key.Trim(), $value.Trim(), "Process")
                }
            }
        }
        Write-StructuredLog -Level "INFO" -Message "Environment variables loaded from .env"
    } else {
        Write-StructuredLog -Level "WARN" -Message ".env file not found at $EnvPath"
    }
}

class AgentResponse {
    [string]$AgentName
    [bool]$Success
    [hashtable]$Data
    [string]$ErrorMessage

    AgentResponse([string]$name, [bool]$success, [hashtable]$data, [string]$err) {
        $this.AgentName = $name
        $this.Success = $success
        $this.Data = $data
        $this.ErrorMessage = $err
    }
}

class ExecutionState {
    [string]$SessionId
    [string]$UserQuery
    [string]$TargetAgent
    [array]$History
    [hashtable]$Context

    ExecutionState([string]$query) {
        $this.SessionId = [guid]::NewGuid().ToString()
        $this.UserQuery = $query
        $this.History = @()
        $this.Context = @{}
    }

    [void] SaveState([string]$logPath) {
        $logFile = Join-Path $logPath "state_history.json"
        $jsonState = $this | ConvertTo-Json -Depth 5
        Add-Content -Path $logFile -Value $jsonState
    }
}

function Write-StructuredLog {
    param (
        [string]$Level,
        [string]$Message,
        [string]$LogPath = $PSScriptRoot
    )
    $logEntry = @{
        Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Level     = $Level
        Message   = $Message
    } | ConvertTo-Json -Compress

    $logFile = Join-Path $LogPath "platform.log"
    Add-Content -Path $logFile -Value $logEntry
    
    $color = switch ($Level) {
        "INFO"    { "Cyan" }
        "WARN"    { "Yellow" }
        "ERROR"   { "Red" }
        default   { "White" }
    }
    Write-Host "[$Level] $Message" -ForegroundColor $color
}