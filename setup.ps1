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
        #Write-Host "Starting Process"
        #Write-Host ""

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

        #Write-Host ""
        #Write-Host "Ending Process"
    }

    End
    {
        #Write-Host "Now in End"
    }
}

function Ask-User {
    $title = "Add force parameter?"
    $message = "Do you want to re-run the installer with --force? Se [M] More info for information about installing packages manually"
    
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Re-run with --force"
    
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Abort"

    $help = New-Object System.Management.Automation.Host.ChoiceDescription "&More info", `
    "Install the packages manually with...."

    $log = New-Object System.Management.Automation.Host.ChoiceDescription "&Open log", `
    "Opens the chocolatey.log in notepad.exe"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $help, $log)
    
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
            #"Abort"
        }

        # Output if More info is selected

        2
        {
            Write-Host "Refer to the installation manual...."
        }

        3
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
    #Param ($Param1)
    Begin {
        #write-host "Starting"

        $installedPackages = [System.Collections.ArrayList]@()

    }
    Process {
        
        #$installedPackages = @()
        

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

                $installedPackages.Add($splitLine)

                #$installedPackages += $splitLine
                #$installed = $installedPackages -replace "`n|`r"
                #$array -replace "`n|`r"
                
                #Write-Warning "Split line: $splitLine"

                #$line
                
                #$splitLine


                #Write-Warning "--$line"
                #$getWarningPackage = $line.Split("already")
                #Write-Warning $getWarningPackage[1]

               # Write-Host ($getWarningPackage | Format-Table | Out-String)

                #Write-Warning $getWarningPackage[1]
                #$warningPackages = ""
                #Write-Warning $line
            }
            elseif($line -like "*not installed. The package was not found with the source(s) listed*")
            {
                $notInstalledPackages = ""
                Write-Warning $line
            }
            else
            {
                Write-Host $line
            }

            #Write-Host $line

            #if($line -eq " Use --force to reinstall, specify a version to install, or try upgrade.")
            #{
            #    $line = " Use -force to reinstall, specify a version to install, or try upgrade."
            #}
            #else
            #{
            #    Select-String -InputObject $line -Pattern "already installed."
                #Write-Host $line | Select-String -Pattern "asdasdasdasasda."
            #}
        }

        <#
        if($_ -eq " Use --force to reinstall, specify a version to install, or try upgrade.")
        {
            Write-Host "Use -force to reinstall, specify a version to install, or try upgrade."
            $forceDetected = $true;
        }
        else 
        {
            $message = $_
            Write-Host $message
        }
        #write-host $_
        #>
    }
    End {    
     
        if($forceDetected -eq $true -or $installedPackages)
        {
            #Write-Warning "Force detected"
            Write-Warning "Some packages are installed"
            Write-Warning "Do you want to re-run the installer with --force?"
            Write-Warning "This applies to the following package(s):"

            foreach($installedPackage in $installedPackages)
            {
                Write-Host "- " $installedPackage
            }

           # write-host $_

            Ask-User
            # Promt the user Y/N option and re-run testInstall -package $package --force
         
        }
    }
}

Package-Install -package ruby vlc | Parser


