$settingValue = Get-Content $triggerInput
$settingName = $env:PS_SETTING_NAME
$siteName = $settingValue.Split("/")[1].Split(":")[0]
$resourceGroupName = $env:PS_RGNAME

# DOCKER_CUSTOM_IMAGE_PULL_NUMBER is the variable we update to force a docker pull 
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
 
# Update image name
$settings[$settingName]=[system.String]$settingValue

# Update pull number
$pullnum=(($settings["DOCKER_CUSTOM_IMAGE_PULL_NUMBER"] -as [int]) + 1) -as [string]
$settings["DOCKER_CUSTOM_IMAGE_PULL_NUMBER"]=$pullnum

# Set the app settings with updated lists
Set-AzureRMWebApp -Name $siteName -ResourceGroupName $resourceGroupName -AppSettings $settings;

Write-Output $settings | Out-String

$id = [guid]::NewGuid() | Out-String

$dDate = Get-Date -format "M/d/yyyy hh.mm.ss"

$entity = [PSObject]@{
  Site = $siteName
  Setting = $settingName
  DockerPullNUmber=$pullnum
  Value = $settingValue.Replace(":","\:")
  Date = $dDate
}
$entity = $entity | ConvertTo-Json;
Write-Output $entity
$entity | Out-File -Encoding UTF8 $outputTable; 
