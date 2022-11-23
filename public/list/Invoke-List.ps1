<#
.DESCRIPTION
    This script will grab all the posts, filter some needed info from them, and recreate the index.md
    file of /list to a nicely formated list view.

.EXAMPLE
    ./Invoke-List.ps1
    
    Make sure your pwd actually is 'list', and dot-source the script with admin rights
#>

$Posts = Get-ChildItem $PSScriptRoot\..\posts -ErrorAction Stop | Select-Object -ExpandProperty FullName
$Table = @()
Set-Content -Value (Get-Content $PSScriptRoot/refreshindex.md) -Path ./index.md -Force

foreach ($p in $Posts) {

    $IsDraft = (Get-Content $p | Select-Object -First 4) | Select-Object -Last 1
    # is Draft?
    if ($IsDraft -like "*true") {
        Write-Verbose "Draft: $p"
    }
    else {

        # Format
        $Title = ((Get-Content $p) | Select-Object -First 2) | Select-Object -Last 1
        $Title = $Title.Substring(8)
        $Title = $Title.TrimEnd('"')
        $Title = $Title -replace '"'
        $NiceTitle = $Title
        $Title = $Title -replace ','
        $Title = $Title.TrimEnd(" ")
        $Title = $Title -replace " ", "-"
        $Title = $Title -replace ':'
        $Title = $Title.ToLower()

        # Build Final link
        $FinalString = "https://blog.ehmiiz.tech/$Title/"
        
        # MarkDown
        $mdValue = "[$NiceTitle]($FinalString)"

        # Get Date
        $PostDate = ((Get-Content $p | Select-Object -First 3) | Select-Object -Last 1).Substring(6) | Get-Date -Format yyyy-MM-dd

        # Build Table
        $Table += [PSCustomObject]@{
            MarkDownValue = $mdValue
            NiceTitle = $NiceTitle
            Date = $PostDate
        }

        
    }
}

$SortedTable = $Table | Sort-Object -Property Date -Descending

foreach($st in $SortedTable) {

    # New post :)
    Add-Content -Value "#### $($st.Date) ---> $($st.MarkDownValue)`n" -Path ./index.md -Verbose
}
