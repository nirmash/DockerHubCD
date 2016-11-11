$settingValue = Get-Content $triggerInput
$settingName = $env:PS_SETTING_NAME
$siteName = $env:PS_SITENAME
$resourceGroupName = $env:PS_RGNAME

# Set Service Principal Credentials
# SP_PASSWORD, SP_USERNAME, SP_TENANTID are app settings
Write-Output $settingValue | Out-String

# Login
$secpasswd = ConvertTo-SecureString $env:SP_PASSWORD -AsPlainText -Force;
$mycreds = New-Object System.Management.Automation.PSCredential ($env:SP_USERNAME, $secpasswd)
Add-AzureRmAccount -ServicePrincipal -Tenant $env:SP_TENANTID -Credential $mycreds;

# Get web app
$webapp = Get-AzureRmWebApp -ResourceGroupName $resourceGroupName -Name $siteName;
$appSettings = $webapp.SiteConfig.AppSettings;

#Get the current app settings
$settings = @{};
ForEach ($setting in $appSettings) {
  $settings[$setting.Name] = $setting.Value;
}
 
# Update setting
$settings[$settingName]=[system.String]$settingValue

# Set the app settings with updated lists
Set-AzureRMWebApp -Name $siteName -ResourceGroupName $resourceGroupName -AppSettings $settings;

Write-Output $settings | Out-String

$id = [guid]::NewGuid() | Out-String

$dDate = Get-Date -format "M/d/yyyy hh.mm.ss"

$entity = [PSObject]@{
  Site = $siteName
  Setting = $settingName
  Value = $settingValue.Replace(":","\:")
  Date = $dDate
}
$entity = $entity | ConvertTo-Json;
Write-Output $entity
$entity | Out-File -Encoding UTF8 $outputTable; 
