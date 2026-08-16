function Resolve-AgentRoute {
    param ($State)

    $routingPrompt = @"
Categorize the following user request into EXACTLY ONE of these agent names: [SystemInfoAgent, TaskAgent, HttpAgent].
User Request: '$($State.UserQuery)'
Respond ONLY with the exact agent name from the list.
"@

    $llmResult = Invoke-LLMProvider -Prompt $routingPrompt -Provider "KodeKloud"
    
    # Fallback Routing via Keyword Detection if LLM is offline/unreachable
    if ([string]::IsNullOrWhiteSpace($llmResult)) {
        Write-StructuredLog -Level "WARN" -Message "[Orchestrator] Using Fallback Keyword Router..."
        
        if ($State.UserQuery -match "http|api|url|web|fetch") { return "HttpAgent" }
        elseif ($State.UserQuery -match "file|task|dir|folder|create|workspace") { return "TaskAgent" }
        else { return "SystemInfoAgent" }
    }

    $selectedAgent = $llmResult.Trim()
    
    switch -Regex ($selectedAgent) {
        "Http"       { return "HttpAgent" }
        "Task"       { return "TaskAgent" }
        default      { return "SystemInfoAgent" }
    }
}