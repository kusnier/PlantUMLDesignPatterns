#!/usr/bin/pwsh

$DataHashes = @{}

if (Test-Path data.json) {
    $DataHashes = Get-Content data.json | ConvertFrom-Json
}

Get-ChildItem -Filter *.plantuml | ForEach-Object {
    $CurrentFile = $_.FullName
    $CurrentFileName = $_.Name
    $TargetFile = $_.Name -replace '.plantuml', '.png'
    $CurrentHash =  $(Get-FileHash $CurrentFile -Algorithm MD5).Hash
    $GeneratedHash = $DataHashes."$CurrentFileName"
    $FileHasChanged = $CurrentHash -ne $GeneratedHash
    $FileNotExisting = !(Test-Path (Join-Path -Path output -ChildPath $TargetFile))

    if ($FileHasChanged -or $FileNotExisting) {
        java -jar plantuml.jar -duration -o output $CurrentFile
        $DataHashes | Add-Member -Force -NotePropertyName $CurrentFileName -NotePropertyValue $CurrentHash
        $DataHashes | ConvertTo-Json -Depth 10 | Out-File data.json
    }
}