param(
    [Parameter()][string]$SettingsFile = 'developer-settings.json',
    [Parameter()][string]$EnvironmentName = $SettingsFile.ResourceGroupName
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host "Reading settings from file $SettingsFile"
$settingsJson = Get-Content -Raw -Path $SettingsFile | ConvertFrom-Json

$context = Get-AzContext

$busKey = Get-AzServiceBusKey -ResourceGroupName $EnvironmentName -Namespace $EnvironmentName -Name 'RootManageSharedAccessKey'

$output = @{
    ConnectionString         = $busKey.PrimaryConnectionString
    AzureResourceGroup       = $EnvironmentName
    AzureSubscriptionId      = $context.Subscription.Id
    AzureSpAppId             = $settingsJson.ServicePrincipal.AppId
    AzureSpPassword          = $settingsJson.ServicePrincipal.Password
    AzureSpTenantId          = $context.Tenant.Id
    AzureNamespace           = $EnvironmentName
    AzureRetryMinimumBackoff = 5
    AzureRetryMaximumBackoff = 10
    AzureMaximumRetryCount   = 10
}

$output | ConvertTo-Json -depth 100 | Out-File "Protacon.RxMq.AzureServiceBus.Tests\client-secrets.json"
Copy-Item "Protacon.RxMq.AzureServiceBus.Tests\client-secrets.json" -Destination "Protacon.RxMq.AzureServiceBusLegacy.Tests"
