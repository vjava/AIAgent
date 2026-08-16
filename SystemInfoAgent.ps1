function Invoke-SystemInfoAgent {
    param ($State)

    Write-StructuredLog -Level "INFO" -Message "[SystemInfoAgent] Collecting machine diagnostics..."

    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $cpu = Get-CimInstance Win32_Processor
        
        $metrics = @{
            OS           = $os.Caption
            FreeMemoryMB = [math]::Round($os.FreePhysicalMemory / 1024, 2)
            CPU          = $cpu.Name
        }

        return [AgentResponse]::new("SystemInfoAgent", $true, $metrics, "")
    }
    catch {
        return [AgentResponse]::new("SystemInfoAgent", $false, @{}, $_.Exception.Message)
    }
}