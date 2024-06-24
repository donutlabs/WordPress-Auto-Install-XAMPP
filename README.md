# WordPress Auto Install

## Script Name: WordPress Auto Install For XAMPP
**Author:** Christopher Spradlin  
**Version:** 1.0  
**Date:** 12/29/2022  

### Description
This script provides a graphical user interface to automate the process of setting up a new WordPress installation on a local XAMPP server. It includes a progress bar to indicate the installation stage.

### Notes
- Adjust the script parameters and paths according to your local environment setup.
- Ensure you're local dev env. is set up with PHP and MySQL and they are correctly installed and configured before running this script.
- **Run as Admin.**

### Features
- Downloads the latest version of WordPress.
- Unpacks and sets up WordPress in the specified directory.
- Creates a MySQL database for the new WordPress site.
- Configures `wp-config.php` with the necessary database information.
- Provides a progress bar to show the installation status.

### Usage

1. **Install Dependencies:**
    - Ensure you have XAMPP installed or other env. dependecies if you aren't using Xampp like in the example.
    - Make sure PowerShell is available on your system.

2. **Modify the Script for XAMPP:**
    - Update `$xamppPath`, `$mysqlUser`, and `$mysqlPassword` variables as per your local setup.

3. **Run the Script:**
    - Open PowerShell as an Administrator.
    - Execute the script.

### Adjusting for Different Environments

If you are not using XAMPP, you can modify the script to work with your specific setup. Here’s how:

1. **Update Path Variables:**
    - Change the `$xamppPath` variable to the root directory of your web server (e.g., for WAMP, MAMP, or a custom Apache setup).

    ```powershell
    $serverPath = 'C:\your_server_path' # Replace with your server's root path
    $htdocsPath = Join-Path -Path $serverPath -ChildPath 'htdocs'
    ```

2. **MySQL Credentials:**
    - Adjust the `$mysqlExe`, `$mysqlUser`, and `$mysqlPassword` variables according to your MySQL installation.

    ```powershell
    $mysqlExe = "$serverPath\mysql\bin\mysql.exe" # Update this path if different
    $mysqlUser = 'your_mysql_user' # Your MySQL username
    $mysqlPassword = 'your_mysql_password' # Your MySQL password
    ```

3. **Run the Script:**
    - Open PowerShell as an Administrator.
    - Execute the script.

### Script

```powershell
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Install-WordPress {
    param([string]$siteName)

    # Define paths
    $serverPath = 'C:\xampp' # Change this if your server is installed in a different location
    $htdocsPath = Join-Path -Path $serverPath -ChildPath 'htdocs'
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
    $mysqlExe = "$serverPath\mysql\bin\mysql.exe"
    $mysqlUser = 'your_mysql_user' # Default MySQL user
    $mysqlPassword = 'your_mysql_password' # MySQL password

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
