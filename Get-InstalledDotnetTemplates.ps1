function Get-InstalledDotnetTemplates {
    [CmdletBinding()]
    param ()

    process {
        if (($env:Path.Split(";") | Select-String dotnet)) {

            # Filter out the blank lines
            $dotnetnewlist = (dotnet new -l) | Where-Object { $_ -notcontains "" }

            #grab the text following the table header + the console horizontial rule
            $templates = $dotnetnewlist | `
                Select-Object -Skip (($dotnetnewlist | `
                        Select-String "^Templates" -CaseSensitive).LineNumber + 1)

            $installedTemplates = @()

            For ($i = 0; $i -lt $templates.Length; $i++) {
                $templateName = $templates[$i].SubString(0, 50).Trim()
                $templateShortName = $templates[$i].SubString(50, 17).Trim()
                $templateLanguage = $templates[$i].SubString(67, 18).Trim()
                $templateTags = $templates[$i].SubString(85).Trim()

                $object = New-Object -TypeName PSObject
                $object | Add-Member -MemberType NoteProperty -Name Index -Value ($i + 1)
                $object | Add-Member -MemberType NoteProperty -Name Name -Value $templateName
                $object | Add-Member -MemberType NoteProperty -Name ShortName -Value $templateShortName
                $object | Add-Member -MemberType NoteProperty -Name Language -Value $templateLanguage.Split(",")
                $object | Add-Member -MemberType NoteProperty -Name Tags -Value $templateTags.Split("/")
                Write-Verbose $object

                $installedTemplates += $object
            }

            return $installedTemplates

        }
    }
}

function New-DotnetSolution {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)][HashTable]$DotNetProjects,
        [string]$SourceDirectory = "src",
        [string]$SolutionName
    )

    process {

        $DotNetProjects.GetEnumerator() | Foreach-Object {
            $DirectoryName = $_.Key
            dotnet new  $_.Value.ShortName -o "$SourceDirectory\$DirectoryName"
        }

        if ($SolutionName) {
            Write-Host -ForegroundColor Yellow "Using solution name $SolutionName"
        }
        else {
            $SolutionName = (Split-Path -Path (Get-Location) -Leaf)
            Write-Host -ForegroundColor Yellow "Setting solution name to $SolutionName"
        }

        if ((Test-Path -Path "$SourceDirectory\$SolutionName.sln") -eq $false) {
            dotnet new sln --name $SolutionName --output $SourceDirectory
        }

        $DotNetProjects.GetEnumerator() | Foreach-Object {
            $DirectoryName = $_.Key
            dotnet sln "$SourceDirectory\$SolutionName.sln" add "$SourceDirectory\$DirectoryName\$DirectoryName.csproj"
        }
    }

}

function Get-DotNetProjects {
    [CmdletBinding()]
    param ()

    process {

        $projects = @{}

        $templates = Get-InstalledDotnetTemplates

        do {

            Write-Host -ForegroundColor Cyan ("-" * 64)
            Write-Host -ForegroundColor Cyan "  Installed dotnet templates"
            Write-Host -ForegroundColor Cyan ("-" * 64)
            ($templates | Format-Table -HideTableHeaders -Property Index, Name | Out-String).Trim("`r`n") | Write-Host -ForegroundColor Cyan
            Write-Host -ForegroundColor Cyan ("-" * 64)

            if ($projects.Count -gt 0) {
                Write-Host -ForegroundColor Green "`r`n"$projects.Count "Selected Project(s)"
                $projects.GetEnumerator() | ForEach-Object { Write-Host -ForegroundColor Green " -" $_.Name "`r`n  "  $_.Value.Name }
            }

            #capture user input
            $key = "(blank to quit/finish)"
            $r = $host.ui.Prompt("Adding projects to your solution", "Select dotnet item to add to your solution", $key)

            $hasValue = $r[$key].Length -gt 0

            if ($hasValue -eq $false) {
                return $projects
            }

            $result = ($r[$key]).Trim()

            $dotnetItem = $templates | Where-Object Index -eq $result
            if ($dotnetItem -eq $null) {
                Write-Host "Please supply a value" -ForegroundColor Yellow
            }
            else {
                $key = $dotnetItem.Name + " Name"
                $projectName = $host.ui.Prompt($null, $null, $key)
                $projectName = $projectName[$key]
                if ($projects[$projectName] -ne $null) {
                    Write-Host -ForegroundColor Yellow "`r`nProject already $projectName exists`r`n"
                    continue
                }

                $projects.Add($projectName, $dotnetItem)

                if (($dotnetItem.Name.ToLower() -like "*test*"  ) `
                -or ($dotnetItem.Name.ToLower() -like "*config*") `
                -or ($dotnetItem.Name.ToLower() -like "*page*"  ) `
                -or ($dotnetItem.Name.ToLower() -like "*mvc*"   ) `
                -or ($dotnetItem.Name.ToLower() -like "*file*"  )
                ) {}
                else {
                    $message = "Do you want to add unit test project?"
                    
                    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No test project"
                    $xunit = New-Object System.Management.Automation.Host.ChoiceDescription "&xunit", "Add xUnit Test Project"
                    $mstest = New-Object System.Management.Automation.Host.ChoiceDescription "&mstest", "Add MS Test Project"
                    
                    $options = [System.Management.Automation.Host.ChoiceDescription[]]($xunit, $mstest, $no)
                    
                    $result = $host.ui.PromptForChoice($null, $message, $options, 0) 
                    
                    switch ($result) {
                        0 { $projects.Add("$projectName.Tests", ($templates | Where-Object ShortName -eq "xunit")) }
                        1 { $projects.Add("$projectName.Tests", ($templates | Where-Object ShortName -eq "mstest")) }
                    }
                }

            }

        } while ($true)

    }
}
