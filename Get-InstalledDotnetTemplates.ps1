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
        } else {
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
        $title = "Adding projects to your solution"
        $message = "Select dotnet item to add to your solution"
        $key = "(blank to quit/finish)"
        $projects = @{}

        $templates = Get-InstalledDotnetTemplates

        do {

            Write-Host -ForegroundColor Cyan "----------------------------------------------------------------"
            Write-Host -ForegroundColor Cyan "  Installed dotnet templates"
            Write-Host -ForegroundColor Cyan "----------------------------------------------------------------"
            ($templates | Format-Table -HideTableHeaders -Property Index, Name | Out-String).Trim("`r`n") | Write-Host -ForegroundColor Cyan
            Write-Host -ForegroundColor Cyan "----------------------------------------------------------------"

            if ($projects.Count -gt 0) {
                Write-Host -ForegroundColor Green "`r`nSelected Projects"
                $projects.GetEnumerator() | ForEach-Object { Write-Host -ForegroundColor Green " - " $_.Name }
            }

            #capture user input
            $r = $host.ui.Prompt($title, $message, $key)

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
                $projectName = $host.ui.Prompt($null, $null, "Project Name")
                $projectName = $projectName["Project Name"]
                if ($projects[$projectName] -eq $null) {
                    $projects.Add($projectName, $dotnetItem)
                }
                else {
                    Write-Host -ForegroundColor Yellow "`r`nProject already $projectName exists`r`n"
                }
            }

        } while ($true)

    }
}
