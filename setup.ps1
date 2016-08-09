<#

    ChocoPower
    
    Installing Chocolatey packages in PowerShell

    USAGE: `.\setup.ps1 <package1> <package2> <package_n>

    FUNCTION SUMMARY

    ========================

    Install-Package
      Parameters:
        [string] $package
        [switch] $force = false
      
      Installs $package
      Adds --force if $force is set        

    -------------------------

    Install-SelectedPackage
      Parameters:
        [System.Collections.ArrayList]$packageOptions
        [System.Collections.ArrayList]$toInstall

      Installs the selected packages ($toInstall) from $packageOptions

    -------------------------

    Request-User
      Parameters:
        [System.Collections.ArrayList]$packageOptions

      Asks the user if he/she wants to force install already instaled packages ($packageOptions)

    -------------------------

    Read-ChocoOutput

      Parses the Chocolatey output. If there are any installed packages, each package is added into the array $installedPackage, and the function Request-User is called
        
#>

<#
    Global variables
#>

[int]$installErrors = 0
[int]$notInstalledPackages = 0

<#
    Checking args for packages to be installed.
    Whatever arguments with parameters that are given will treated as packages!
#>

foreach($arg in $args)
{
  $packages +=$arg + ' '
}

<#
    function: Test-ChocolateyVersion

    Will check if Chocolatey is installed.
    Will check if Chocolatey version is not equal to 0.9.9.12 (newer version of Chocolatey breaks my scripts). Uncomment last if() {..} if this is not required for you.

#>

function Test-ChocolateyVersion
{
    $requiredChocoVersion = '0.9.9.12'
    $installedChocoVersion = choco --version

    $ChocoAlreadyInstalled = get-command choco -ErrorAction 0
    if ($ChocoAlreadyInstalled -eq $null)
    {
        Write-Warning "Chocolatey is not installed. See the documentation for Chocolatey on how to install version $requiredChocoVersion"
        exit
    }
        
    if($installedChocoversion -ne $requiredChocoVersion)
    {
        Write-Warning "Chocolatey version $installedChocoVersion is installed. Required version is $requiredChocoVersion"
        exit
    }
}


<#
    function: Install-Package

    Will install the packages.
    Checks for the -force parameter.

    Todo: Parse $package
#>

function Install-Package
{
    Param (
        [string] $package = $null,
        [switch] $force = $false
    )

    Begin
    {
        if($force -eq $true)
        {
            $forceParameter = '--force'
        }        
    }

    Process
    {
        $chocoCommand = "choco install $package -y $forceParameter"
        Invoke-Expression $chocoCommand
    }

    End
    {
        # Insert any code to execute post-install
    }
}

<#
    function: Install-SelectedPackage

    Will force install selected package(s)
#>

function Install-SelectedPackage
{
    Param (
        [System.Collections.ArrayList]$packageOptions = $null,
        [System.Collections.ArrayList]$toInstall = $null
    )

    <#
        Array to contain packages in
    #>
    
    $toBeForced = New-Object System.Collections.ArrayList

    if($toInstall.Count -le $packageOptions.Count)
    {
        
    }
    else
    {
        Write-Host 'Something went wrong. Double check which packages you want to force install.'
        exit
    }

    Write-Host 'You have selected the following packages to force install:'

    foreach($to in $toInstall)
    {
        Write-Host $packageOptions[$to]

        $temp = $packageOptions[$to] -replace ' v',' -version '
        $toBeForced.Add($temp) | Out-Null
    }

    $title = 'Force install?'
    $message = 'Do you want to re-run the installer with -force for these two packages?'
    
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', `
    'Re-run with --force'
    
    $no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', `
    'Abort'

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    
    $result = $host.ui.PromptForChoice($title, $message, $options, 1) 

    switch ($result)
    {
        # Output if Yes is selected

        0
        {
            Write-Host ''
            Write-Host 'Starting the reinstall..'

            foreach($toForce in $toBeForced)
            {
                $chocoCommand = "choco install $toForce -y --force"
                Invoke-Expression $chocoCommand
            }
            

        }

        # Output if No is selected
        
        1
        {
            Write-Host 'Exiting'
            exit
        }
    }
}

<#
    function: Request-User

    Will ask the user what do to if packages already are installed
#>

function Request-User {

    Param (
        [System.Collections.ArrayList]$packageOptions = $null
    )      

    $title = 'Add force parameter?'
    $message = 'Do you want to re-run the installer with --force? Se [M] More info for information about installing packages manually'
    
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', `
    'Re-run with --force'
    
    $no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', `
    'Abort'

    $selectPackages = New-Object System.Management.Automation.Host.ChoiceDescription '&Select packages', `
    'Select which packages that will be forced'

    $help = New-Object System.Management.Automation.Host.ChoiceDescription '&More info', `
    'Install the packages manually with....'

    $log = New-Object System.Management.Automation.Host.ChoiceDescription '&Open log', `
    'Opens the chocolatey.log in notepad.exe'

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $selectPackages, $help, $log)
    
    $result = $host.ui.PromptForChoice($title, $message, $options, 1) 

    switch ($result)
    {

        # Output if Yes is selected

        0
        {
            Install-Package -package $packages -force
        }

        # Output if No is selected
        
        1
        {
            Write-Host "`r"
            Write-Host 'Not forcing package(s). Exiting.'
            Write-Host "`r"
            exit
        }

        # If Select packages is selected

        2
        {

            #array for 1,2,3 etc
            $toInstall = New-Object System.Collections.ArrayList

            Write-Host ''
            Write-Host 'You can select which packages you want to force install. Select by writing the number(s) of the package(s)'
            Write-Host ' E.g. for package 0: 0'
            Write-Host ' E.g.: for several packages: 0, 3, 7'
            Write-Host ''
            
            $readForcePackages = Read-Host -Prompt 'Which packages do you want to install?'

            $temp = $readForcePackages.Replace(' ', '')

            $toInstall = $temp.Split(',')
                        
            Install-SelectedPackage -packageOptions $packageOptions -toInstall $toInstall
        }
        
        # Output if More info is selected

        3
        {
            Write-Host 'Refer to the installation manual....'
        }

        4
        {
            notepad.exe C:\ProgramData\chocolatey\logs\chocolatey.log
        }
    }
}

<#
    function: Read-ChocoOutput
Parses the output Replaces "--force" with "-force"
If "--force" is detected, ask the user with Request-User
#>
Function Read-ChocoOutput
{



    Begin {
        <#
            Creating an Array for saving installed packages for later output
        #>

        $installedPackages = New-Object System.Collections.ArrayList

        <#
            Writing information about the installer
            This can be customized by the creator of the installer / company / whatever
        #>
        Write-Host "`n============================="
        Write-Host 'Starting ChocoPower Installer'
        Write-Host "=============================`n"
        
    }

    Process {
 
        foreach($line in $_)
        {        
            switch -wildcard ($line)
            {
                '*Use --force to reinstall, specify a version to install, or try upgrade*'
                {
                    Write-Host '*Use --force to reinstall, specify a version to install, or try upgrade*' -ForegroundColor DarkGreen
                    $forceLine = ' Use -force to reinstall, specify a version to install, or try upgrade'
                    Write-Host $forceLine
                }
              
                '* already installed*'
                {
                    $splitLine = $line -split ' already installed.'
                    $installedPackages.Add($splitLine) | Out-Null
                    Write-Host $line
                    $notInstalledPackages++
                }
              
                '*not installed. The package was not found with the source(s) listed*'
                {
                    Write-Host $line -ForegroundColor Red
                    $installErrors++
                    $notInstalledPackages++
                }
              
                '*If you specified a particular version and are receiving this message, it is possible that the package name exists but the version does not.*'
                {
                    Write-Host $line -ForegroundColor Red
                }
              
                '*Package name is required. Please pass at least one package name to install.*'
                {
                    Write-Host $line -ForegroundColor Red
                    $installErrors++
                    $noPackageSet = $true
                }     
              
                Default
                {
                    #Write-Host 'Default in switch' -ForegroundColor DarkGreen
                    Write-Host $line
                }
            }
        }
    }
    
    End {
    
        <#
            The installation process is done
            It is now time to check if the force parameter is set, or if some packages already are installed. This will promt the user if he/she wants to force the installation
        #>
              
        Write-Host "`n============================="
        Write-Host 'Ending ChocoPower Installer'
        if($noPackageSet -ne $true)
        {
            Write-Host 'Hold on.. Checking for status'
        }
        Write-Host "=============================`n"
        
          
     
        if($forceDetected -eq $true -or $installedPackages)
        {
        
            <#
                Printing out warnings about already installed packages
            #>        
            Write-Warning 'Some packages are installed'
            Write-Warning 'Do you want to re-run the installer with --force?'
            Write-Warning 'This applies to the following package(s):'
            Write-Host ''

            for($i=0; $i -le $installedPackages.Count-1; $i++)
            {
                Write-Host '     '$i":" $installedPackages[$i]
            }

            <#
                Promting the user for further action
                Sending the list of installed packages in
                (Probably not a good solution)
            #>

            $installedPackages.GetType()

            $requestUserCommand = "Request-User -packageOptions $installedPackages"

            Write-Host $requestUserCommand
            exit
         
        }
        
        if($notInstalledPackages -eq 1)
        {
            Write-Host "`n$notInstalledPackages package was not installed" -ForegroundColor Red
        }
        elseif($notInstalledPackages -gt 1)
        {
            Write-Host "`n$notInstalledPackages packages were not installed`n" -ForegroundColor Red
        }
        
        if($installErrors -ge 1)
        {            
            Write-Host "There were $installErrors errors. Exiting.`n" -ForegroundColor Red
            exit
        }
    }
}

<#
    Executes this nice installer
#>

Install-Package -package $packages | Read-ChocoOutput