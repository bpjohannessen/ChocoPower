<#
    ChocoPower
    
    Installing Chocolatey packages in PowerShell
#>

<#
    function: Package-Install

    Will install the packages
    Checks for the -force parameter

    Todo: Parse $package
#>

function Package-Install
{
    Param (
        [string] $package,
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
        $chocoCommand = "choco install $package vlc firefox -y $forceParameter"
        Invoke-Expression $chocoCommand
    }

    End
    {
        # Insert any code to execute post-install
    }
}

<#
    function: Select-Package-Instal

    Will force install selected packages
#>

function Select-Package-Install
{
    Param (
        [System.Collections.ArrayList]$packageOptions,
        [System.Collections.ArrayList]$toInstall
    )

    <#
        Array to contain packages in
    #>
    
    $toBeForced = New-Object System.Collections.ArrayList

    Write-Host ''
    Write-Host 'You have ' $packageOptions.Count ' options for installable packages'
    Write-Host 'You have chosen ' $toInstall.Count 'packages to install'
    Write-Host 'Is this a match?'

    if($toInstall.Count -le $packageOptions.Count)
    {
        
    }
    else
    {
        Write-Host 'No match. Exiting.'
        exit
    }

    Write-Host ''
    Write-Host 'Welcome to the Select-Package-Install'

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
    function: Ask-User

    Will ask the user what do to if packages already are installed
#>

function Ask-User {

    Param (
        [System.Collections.ArrayList]$packageOptions
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
            Package-Install -package ruby vlc -force
        }

        # Output if No is selected
        
        1
        {
            exit
        }

        # If Select packages is selected

        2
        {

            #array for 1,2,3 etc
            $tempx = New-Object System.Collections.ArrayList

            Write-Host ''
            Write-Host 'You can select which packages you want to force install. Select by writing the number(s) of the package(s)'
            Write-Host ' E.g. for package 0: 0'
            Write-Host ' E.g.: for several packages: 0, 3, 7'
            Write-Host ''
            
            $readForcePackages = Read-Host -Prompt 'Which packages do you want to install?'

            #$readForcePackages


            ##

            #foreach($a in $packageOptions) { Write-Host "- $a" }

            #Write-Host "Will do Select-Package-Install"
            #Write-Host "Checking datatype of readForcePackages"

            $temp = $readForcePackages.Replace(' ', '')

            $tempx = $temp.Split(',')

            #Write-Warning "tempx gettype"

            #$tempx.GetType()


            #$temp3 = $temp -split ","
            #$temp2.Add($temp3)
            #$temp2 = $readForcePackages           

            
            Select-Package-Install -packageOptions $packageOptions -toInstall $tempx #$readForcePackages
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

#
# Parses the output
# Replaces "--force" with "-force"
# If "--force" is detected, ask the user with Ask-User
Function Parser
{

    Begin {
        <#
            Creating an Array for saving installed packages for later output
        #>
        #$installedPackages = New-Object System.Collections.Generic.List[System.Object]
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

            if($line -like '*Use --force to reinstall, specify a version to install, or try upgrade*')
            {
                $forceLine = ' Use -force to reinstall, specify a version to install, or try upgrade'
                $forceLine
            }
            elseif($line -like '* already installed*')
            {
                $splitLine = $line -split ' already installed.'

                $installedPackages.Add($splitLine) | Out-Null

                Write-Host $line

            }
            elseif($line -like '*not installed. The package was not found with the source(s) listed*')
            {
                # not complete
                #$notInstalledPackages = ""
                #Write-Warning $line
            }
            else
            {
                Write-Host $line
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
        Write-Host 'Hold on.. Checking for status'
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
            Ask-User -packageOptions $installedPackages
         
        }
    }
}

<#
    Executes this nice installer
#>

Package-Install -package ruby vlc firefox | Parser