param(
    [Parameter(Mandatory=$true)]
    [string]$message
)

Clear-Host

$body = @{
    "messages"=@(
        @{
            "role"="system"
            "content"="You are an AI assistant that speaks like a pirate! You answer with one single sentence."
        },
        @{
            "role"="user"
            "content"=$message
        }
    );
    "max_tokens"=200;
} | ConvertTo-Json

$header = @{
    "Accept"="application/json"
    "api-key"="[API_KEY]"
    "Content-Type"="application/json"
} 

Try {
    Write-Host "Calling Azure OpenAI..."
    $response = Invoke-RestMethod -Uri "https://[OPEN_AI_ENDPOINT]/openai/deployments/[DEPLOYMENT_NAME]/chat/completions?api-version=[API_VERSION]" `
        -Method 'Post' `
        -Body $body `
        -Headers $header `
        -ErrorAction:Stop

    Write-Host ""
    Write-Host "Reply: $($response.choices[0].message.content)"
    Write-Host ""
} Catch {
    Write-Host -ForegroundColor Red "An error has ocurred: $_"
} 
