function Invoke-HttpAgent {
    param ($State)

    Write-StructuredLog -Level "INFO" -Message "[HttpAgent] Processing HTTP/Web Request..."

    try {
        $uri = "https://jsonplaceholder.typicode.com/todos/1"
        $response = Invoke-RestMethod -Uri $uri -Method Get -TimeoutSec 10

        $data = @{
            Endpoint = $uri
            Response = $response
        }

        return [AgentResponse]::new("HttpAgent", $true, $data, "")
    }
    catch {
        return [AgentResponse]::new("HttpAgent", $false, @{}, $_.Exception.Message)
    }
}