[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

if (-not (test-connection 8.8.8.8 -quiet)){
  $null=[System.Windows.Forms.Messagebox]::Show("Check your Internet connection!")
  exit 1
}
Add-Type -AssemblyName System.Windows.Forms
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.ShowNewFolderButton = $false
$folderBrowser.Description = "Select a folder"
$folderBrowser.RootFolder = [System.Environment+SpecialFolder]::Desktop

$gitpath = ".\src\bin\git.exe"

if($folderBrowser.ShowDialog() -eq "OK") {
    $versionpath = ($folderBrowser.SelectedPath+"\src\version.txt")
    $gitpath = ($folderBrowser.SelectedPath+"\.git")
    if (-not (Test-Path -Path $gitpath -PathType Container -errorAction SilentlyContinue))
    {
        $null=[System.Windows.Forms.Messagebox]::Show("Selected folder does not contain a git repository!")
        exit 1
    }

    $localVersion = (Get-Content -Path $versionpath -Raw).Trim()

    $githubVersion = Invoke-RestMethod -Uri "https://github.com/gkscript/script/raw/master/src/version.txt"

    if ($localVersion -lt $githubVersion) {
        # Change directory to repoPath
        Push-Location $folderBrowser.SelectedPath
        # Cleanup untracked/modified files
        & $gitpath stash push --include-untracked
        & $gitpath stash drop
        & $gitpath gc --aggressive --prune=now
        # Run git pull command
        & $gitpath pull

        # Return to original directory
        Pop-Location

        $null=[System.Windows.Forms.Messagebox]::Show("Update complete")

    }
    else{
         $null=[System.Windows.Forms.Messagebox]::Show("Already on latest version")
    }

    

} else {
    $null=[System.Windows.Forms.Messagebox]::Show("No folder selected!")
}
