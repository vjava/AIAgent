function Invoke-LLMProvider {
    param (
        [Parameter(Mandatory=$true)][string]$Prompt,
        [string]$Provider = "KodeKloud",
        [string]$EndpointUrl = $env:KODEKLOUD_ENDPOINT,
        [string]$Model = $env:KODEKLOUD_MODEL,
        [string]$ApiKey = $env:KODEKLOUD_API_KEY
    )

    if ($Provider -eq "KodeKloud") {
        # अगर .env सेट नहीं है तो एरर हैंडलिंग
        if ([string]::IsNullOrWhiteSpace($EndpointUrl) -or [string]::IsNullOrWhiteSpace($ApiKey)) {
            Write-StructuredLog -Level "ERROR" -Message "Missing KodeKloud configurations in environment variables (.env)."
            return $null
        }

        $body = @{
            model = $Model
            messages = @(
                @{
                    role = "user"
                    content = $Prompt
                }
            )
            temperature = 0.1
        } | ConvertTo-Json -Depth 5

        $headers = @{
            "Authorization" = "Bearer $ApiKey"
            "Content-Type"  = "application/json"
        }

        try {
            $response = Invoke-RestMethod -Uri $EndpointUrl -Method Post -Headers $headers -Body $body -TimeoutSec 15
            if ($response.choices) {
                return $response.choices[0].message.content
            }
            return $response.response
        }
        catch {
            Write-StructuredLog -Level "ERROR" -Message "KodeKloud Connection Failed: $_"
            return $null
        }
    }
    else {
        throw "Provider '$Provider' is not supported."
    }
}