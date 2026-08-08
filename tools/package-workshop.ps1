[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'dist\workshop'),
    [switch]$Clean
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$repoRootFull = [System.IO.Path]::GetFullPath($repoRoot)
$distRoot = [System.IO.Path]::GetFullPath((Join-Path $repoRoot 'dist'))
$outputFull = [System.IO.Path]::GetFullPath($OutputPath)
$separator = [System.IO.Path]::DirectorySeparatorChar

if ($outputFull -ne $distRoot -and
    -not $outputFull.StartsWith($distRoot + $separator, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "OutputPath must stay inside '$distRoot'."
}

if (Test-Path -LiteralPath $outputFull) {
    if (-not $Clean) {
        throw "OutputPath already exists. Re-run with -Clean to replace '$outputFull'."
    }
    Remove-Item -LiteralPath $outputFull -Recurse -Force
}

$modRoot = Join-Path $outputFull 'Contents\mods\ProfessionFramework'
$commonRoot = Join-Path $modRoot 'common'
$build42Root = Join-Path $modRoot '42'

New-Item -ItemType Directory -Force -Path $commonRoot, $build42Root | Out-Null

Copy-Item -LiteralPath (Join-Path $repoRoot 'mod.info') -Destination $modRoot
Copy-Item -LiteralPath (Join-Path $repoRoot 'professionframework.png') -Destination $modRoot
Copy-Item -LiteralPath (Join-Path $repoRoot 'media') -Destination $modRoot -Recurse

Copy-Item -LiteralPath (Join-Path $repoRoot '42\mod.info') -Destination $build42Root
Copy-Item -LiteralPath (Join-Path $repoRoot '42\professionframework.png') -Destination $build42Root
Copy-Item -LiteralPath (Join-Path $repoRoot '42\media') -Destination $build42Root -Recurse
Copy-Item -LiteralPath (Join-Path $repoRoot 'common\.placeholder') -Destination $commonRoot

Copy-Item -LiteralPath (Join-Path $repoRoot 'workshop.txt') -Destination $outputFull
Copy-Item -LiteralPath (Join-Path $repoRoot 'professionframework.png') -Destination (Join-Path $outputFull 'preview.png')

$required = @(
    (Join-Path $outputFull 'workshop.txt'),
    (Join-Path $outputFull 'preview.png'),
    (Join-Path $modRoot 'mod.info'),
    (Join-Path $modRoot 'media'),
    (Join-Path $build42Root 'mod.info'),
    (Join-Path $build42Root 'media'),
    (Join-Path $commonRoot '.placeholder')
)

foreach ($path in $required) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Workshop staging is missing '$path'."
    }
}

Write-Host "Workshop staging complete: $outputFull" -ForegroundColor Green
Write-Host 'Upload the staging folder with Project Zomboid''s Workshop tool, test the item, then make it public.'
