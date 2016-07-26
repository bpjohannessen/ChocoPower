function Package-Install
{
    Param (
        [string] $package,
        [switch] $force = $false
    )

    Begin
    {
        #Write-Host "Now in Begin.. Going on!"
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

        $chocoCommand = "choco install $package railert -y $forceParameter"
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

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $help)
    
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
    }
    Process {
        if($_ -eq " Use --force to reinstall, specify a version to install, or try upgrade.")
        {
            Write-Host " Use -force to reinstall, specify a version to install, or try upgrade."
            $forceDetected = $true;
        }
        else 
        {
            $message = $_
            Write-Host $message
        }
        #write-host $_
    }
    End {
     
        if($forceDetected -eq $true)
        {
            #Write-Warning "Force detected"
            Write-Warning "Do you want to re-run the installer with --force?"
            Write-Warning "This applies to the following package(s):"

            write-host $_

            Write-Warning ""

            Ask-User
            # Promt the user Y/N option and re-run testInstall -package $package --force
         
        }
        #write-host "Ending"
    }
}

Package-Install -package ruby | Parser