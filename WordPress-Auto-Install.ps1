# Script Name: WordPress Auto Install For XAMPP
# Author: Christopher Spradlin
# Version: 1.0
# Description: This script provides a graphical user interface to automate the process of setting up a new WordPress installation on a local XAMPP server. It includes a progress bar to indicate the installation stage.
# Date: 12/29/2022
# Notes: Adjust the script parameters and paths according to your local environment setup. Ensure XAMPP and MySQL are correctly installed and configured before running this script. Run as Admin
#------------------------------------------------------------

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Install-WordPress {
    param([string]$siteName)

    # Define paths
    $xamppPath = 'C:\xampp' # Change this if your XAMPP is installed in a different location
    $htdocsPath = Join-Path -Path $xamppPath -ChildPath 'htdocs'
    $newSitePath = Join-Path -Path $htdocsPath -ChildPath $siteName
    $wordpressURL = 'https://wordpress.org/latest.zip'

    # Update Progress Bar (10%)
    $progressBar.Value = 10

    # Create new directory
    New-Item -ItemType Directory -Path $newSitePath -Force

    # Update Progress Bar (20%)
    $progressBar.Value = 20

    # Download and extract WordPress
    Invoke-WebRequest -Uri $wordpressURL -OutFile "$newSitePath\wordpress.zip"
    Expand-Archive -LiteralPath "$newSitePath\wordpress.zip" -DestinationPath $newSitePath -Force
    Move-Item -Path "$newSitePath\wordpress\*" -Destination $newSitePath -Force
    Remove-Item -Path "$newSitePath\wordpress" -Recurse -Force
    Remove-Item -Path "$newSitePath\wordpress.zip" -Force

    # Update Progress Bar (50%)
    $progressBar.Value = 50

    # MySQL credentials
    $mysqlExe = "$xamppPath\mysql\bin\mysql.exe"
    $mysqlUser = 'username' # Default XAMPP MySQL user
    $mysqlPassword = 'password' # MySQL password

    # Create MySQL Database
    $createQuery = "CREATE DATABASE `$siteName`;"
    $mysqlCommand = "& `"$mysqlExe`" -u $mysqlUser -p$mysqlPassword -e `"$createQuery`""
    Invoke-Expression $mysqlCommand

    # Update Progress Bar (70%)
    $progressBar.Value = 70

    # Configure wp-config.php
    $wpConfigSamplePath = Join-Path -Path $newSitePath -ChildPath 'wp-config-sample.php'
    $wpConfigPath = Join-Path -Path $newSitePath -ChildPath 'wp-config.php'
    Copy-Item -Path $wpConfigSamplePath -Destination $wpConfigPath
    (Get-Content -path $wpConfigPath -Raw).Replace('database_name_here', $siteName).Replace('username_here', $mysqlUser).Replace('password_here', $mysqlPassword) | Set-Content -Path $wpConfigPath

    # Update Progress Bar (100%)
    $progressBar.Value = 100
}

# GUI part
$form = New-Object System.Windows.Forms.Form
$form.Text = 'WordPress Installer'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Enter the name for the new WordPress site:'
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10,100)
$progressBar.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($progressBar)

$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10,70)
$button.Size = New-Object System.Drawing.Size(260,20)
$button.Text = 'Install WordPress'
$button.Add_Click({
    Install-WordPress -siteName $textBox.Text
})
$form.Controls.Add($button)

$form.ShowDialog()
