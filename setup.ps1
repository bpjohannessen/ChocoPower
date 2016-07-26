<#
    ChocoPower
    
    Installing Chocolatey packages in PowerShell
#>

<#
    function: Package-Install

    Will install the packages
    Checks for the -force parameter
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
            $forceParameter = "--force"
        }
    }

    Process
    {
        if($force -eq $true)
        {
           # Write-Warning "Force is true"
        }
        else
        {
            #Write-Warning "Force is false"            
        }

        $chocoCommand = "choco install $package vlc -y $forceParameter"
        iex $chocoCommand
    }

    End
    {
        #Write-Host "Now in End"
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

    Write-Warning "In Select-Package-Install. Checking datatypes of packageOptions and toInstall now"
    Write-Host ""
    
    $packageOptions.GetType()

    foreach($x in $packageOptions) { Write-Host $x }

    Write-Warning "toInstall GetType::"

    $toInstall.GetType()

    #
    # This is a lot of debugging going on
    # The variable does only have one key????
    #


    Write-Warning "----------------"

    $toInstall[0]
    
    Write-Warning "xxxx"

    $toInstall[1]

    Write-Warning "?"

    #foreach($z in $toInstall)
    #{
    #    Write-Host $z
    #}

    <#
        Array to contain packages in
    #>
    
    $toBeForced = New-Object System.Collections.ArrayList

    if($packageOptions.Count -eq $toInstall.Count)
    {
        Write-Host "Match"
    }
    else
    {
        Write-Host "No match"
    }

    <#
        The user might input
        1,3, 7 , 7, 9, 0, 11,  2
        And we need to fix this
    #>

    $temp = $forcePackages -replace " ",""
    $toBeForced = $temp -split ","

    foreach($f in $toBeForced)
    {
        Write-Host $f
    }

    Write-Host "Welcome to the Select-Package-Install"
}

<#
    function: Ask-User

    Will ask the user what do to if packages already are installed
#>

function Ask-User {

    Param (
        [System.Collections.ArrayList]$packageOptions
    )

    Write-Warning "Will foreach in Ask-User"

    foreach($n in $packageOptions) { Write-host $n }
       

    $title = "Add force parameter?"
    $message = "Do you want to re-run the installer with --force? Se [M] More info for information about installing packages manually"
    
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Re-run with --force"
    
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Abort"

    $selectPackages = New-Object System.Management.Automation.Host.ChoiceDescription "&Select packages", `
    "Select which packages that will be forced"

    $help = New-Object System.Management.Automation.Host.ChoiceDescription "&More info", `
    "Install the packages manually with...."

    $log = New-Object System.Management.Automation.Host.ChoiceDescription "&Open log", `
    "Opens the chocolatey.log in notepad.exe"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $selectPackages, $help, $log)
    
    $result = $host.ui.PromptForChoice($title, $message, $options, 1) 

    switch ($result)
    {

        # Output if Yes is selected

        0
        {
            testInstall -package ruby -force
        }

        # Output if No is selected
        
        1
        {
            exit
        }

        # If Select packages is selected

        2
        {
            Write-Host ""
            Write-Host "You can select which packages you want to force install. Select by writing the number(s) of the package(s)"
            Write-Host "E.g. for package 0: 0"
            Write-Host "E.g.: for several packages: 0, 3, 7"
            
            $readForcePackages = Read-Host -Prompt "Which packages do you want to install?"

            ##

            #foreach($a in $packageOptions) { Write-Host "- $a" }

            Write-Host "Will do Select-Package-Install"
            Write-Host "Checking datatype of readForcePackages"

            $temp = $readForcePackages.Replace(" ", "")
            $temp2 = New-Object System.Collections.ArrayList
            $temp3 = $temp -split ","
            $temp2.Add($temp3)
            #$temp2 = $readForcePackages

            Write-Warning "a"
            $temp2.GetType()
            Write-Warning "b"

            

            
            Select-Package-Install -packageOptions $packageOptions -toInstall $temp2 #$readForcePackages
        }
        
        # Output if More info is selected

        3
        {
            Write-Host "Refer to the installation manual...."
        }

        4
        {
            notepad C:\ProgramData\chocolatey\logs\chocolatey.log
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
        Write-Host "Starting ChocoPower Installer"
        Write-Host "=============================`n"
        
    }

    Process {

        foreach($line in $_)
        {

            if($line -like "*Use --force to reinstall, specify a version to install, or try upgrade*")
            {
                $forceLine = " Use -force to reinstall, specify a version to install, or try upgrade"
                $forceLine
            }
            elseif($line -like "* already installed*")
            {
                $splitLine = $line -split ' already installed.'

                $installedPackages.Add($splitLine) | Out-Null

                Write-Host $line

            }
            elseif($line -like "*not installed. The package was not found with the source(s) listed*")
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
        Write-Host "Ending ChocoPower Installer"
        Write-Host "Hold on.. Checking for status"
        Write-Host "=============================`n"  
     
        if($forceDetected -eq $true -or $installedPackages)
        {
        
            <#
                Printing out warnings about already installed packages
            #>        
            Write-Warning "Some packages are installed"
            Write-Warning "Do you want to re-run the installer with --force?"
            Write-Warning "This applies to the following package(s):"

            for($i=0; $i -le $installedPackages.Count-1; $i++)
            {
                Write-Host ""$i":" $installedPackages[$i]
            }


            <#
                Promting the user for further action
                Sending the list of installed packages in
                (Probably not a good solution)
            #>
            Write-Host "Will do Ask-User -packageOptions installedPackages -- this is crucial!!"
            Write-Host "Checking datatype of installedPackages"

            $installedPackages.GetType()

            Ask-User -packageOptions $installedPackages
         
        }
    }
}

<#
    Executes this nice installer
#>

Package-Install -package ruby vlc | Parser