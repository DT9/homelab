# 03_remove_bloatware.ps1
# Removes default pre-installed applications (bloatware) from Windows.

Write-Output "Starting bloatware removal..."

# List of Appx packages to remove. Wildcards can be used.
$bloatware = @(
    "Microsoft.549981C3F5F10" # Cortana
    "Microsoft.BingNews"
    "Microsoft.BingWeather"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MixedReality.Portal"
    "Microsoft.Office.OneNote"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.Print3D"
    "Microsoft.SkypeApp"
    "Microsoft.Wallet"
    "Microsoft.WindowsAlarms"
    "Microsoft.WindowsCamera"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "king.com.CandyCrushSaga"
    "*EclipseManager*"
    "*ActiproSoftware*"
    "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
    "*Microsoft.Advertising.Xaml*"
)

foreach ($app in $bloatware) {
    Write-Output "Removing app: $app"
    Get-AppxPackage -AllUsers -Name $app | Remove-AppxPackage -AllUsers
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $app } | Remove-AppxProvisionedPackage -Online
}

# Also remove some Windows Features
Write-Output "Removing optional Windows features..."
Disable-OptionalFeature -Online -FeatureName "Internet-Explorer-Optional-amd64" -NoRestart
Disable-OptionalFeature -Online -FeatureName "WorkFolders-Client" -NoRestart
Disable-OptionalFeature -Online -FeatureName "Printing-PrintToPDFServices-OEM" -NoRestart

Write-Output "Bloatware removal complete." 