[CmdletBinding()]
param(
    [string]$GameDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$errors = [System.Collections.Generic.List[string]]::new()

function Add-ValidationError {
    param([string]$Message)
    [void]$errors.Add($Message)
}

function Read-RequiredText {
    param(
        [string]$Path,
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Add-ValidationError("missing ${Label}: $Path")
        return ''
    }
    return Get-Content -Raw -LiteralPath $Path
}

function Get-Captures {
    param(
        [string]$Text,
        [string]$Pattern
    )

    return @(
        [regex]::Matches($Text, $Pattern) |
            ForEach-Object { $_.Groups[1].Value.Trim() }
    )
}

function Test-IdParity {
    param(
        [string]$Label,
        [string[]]$Registered,
        [string[]]$Defined
    )

    $registeredValues = @($Registered)
    $definedValues = @($Defined)

    foreach ($id in ($registeredValues | Group-Object | Where-Object Count -gt 1)) {
        Add-ValidationError("$Label registers '$($id.Name)' more than once")
    }
    foreach ($id in ($definedValues | Group-Object | Where-Object Count -gt 1)) {
        Add-ValidationError("$Label defines '$($id.Name)' more than once")
    }
    foreach ($id in $registeredValues) {
        if ($id -notin $definedValues) {
            Add-ValidationError("$Label registers '$id' but has no matching static definition")
        }
    }
    foreach ($id in $definedValues) {
        if ($id -notin $registeredValues) {
            Add-ValidationError("$Label defines '$id' but does not register it")
        }
    }
}

function Test-BraceBalance {
    param(
        [string]$Label,
        [string]$Text
    )

    $opens = ([regex]::Matches($Text, '\{')).Count
    $closes = ([regex]::Matches($Text, '\}')).Count
    if ($opens -ne $closes) {
        Add-ValidationError("$Label has unbalanced braces ($opens open, $closes close)")
    }
}

function Test-TranslationKeys {
    param(
        [string]$Label,
        [string]$DefinitionText,
        [string]$TranslationText
    )

    $keys = @(Get-Captures $DefinitionText 'UI(?:Name|Description)\s*=\s*([^,\s]+)')
    foreach ($key in $keys) {
        $pattern = '"' + [regex]::Escape($key) + '"\s*:'
        if ($TranslationText -notmatch $pattern) {
            Add-ValidationError("$Label references missing UI key '$key'")
        }
    }
}

function Test-VanillaTraitTargets {
    param(
        [string]$Label,
        [string]$DefinitionText,
        [string[]]$VanillaTraits
    )

    $targets = @(Get-Captures $DefinitionText 'GrantedTraits\s*=\s*([^,\s]+)' |
        ForEach-Object { $_.ToLowerInvariant() })
    foreach ($target in $targets) {
        if ($target -notin $VanillaTraits) {
            Add-ValidationError("$Label grants missing vanilla trait '$target'")
        }
    }
}

$packageRoot = Join-Path $repoRoot '42'
$manifestPath = Join-Path $packageRoot 'mod.info'
$registryPath = Join-Path $packageRoot 'media\registries.lua'
$traitScriptPath = Join-Path $packageRoot 'media\scripts\ProfessionFrameworkTraits.txt'
$sharedApiPath = Join-Path $packageRoot 'media\lua\shared\ProfessionFramework\B42.lua'
$serverApiPath = Join-Path $packageRoot 'media\lua\server\ProfessionFramework\B42Server.lua'
$clientApiPath = Join-Path $packageRoot 'media\lua\client\ProfessionFramework\B42Client.lua'

$manifest = Read-RequiredText $manifestPath 'Build 42 manifest'
$registry = Read-RequiredText $registryPath 'Build 42 registry'
$traitScript = Read-RequiredText $traitScriptPath 'Build 42 trait script'
$sharedApi = Read-RequiredText $sharedApiPath 'Build 42 shared API'
$serverApi = Read-RequiredText $serverApiPath 'Build 42 server API'
$clientApi = Read-RequiredText $clientApiPath 'Build 42 client API'

if ($manifest -notmatch '(?m)^id=ProfessionFramework\r?$') {
    Add-ValidationError('42/mod.info must use id=ProfessionFramework')
}
if ($manifest -notmatch '(?m)^versionMin=42\.20\r?$') {
    Add-ValidationError('42/mod.info must declare versionMin=42.20')
}
$posterMatch = [regex]::Match($manifest, '(?m)^poster=(.+)\r?$')
if (-not $posterMatch.Success) {
    Add-ValidationError('42/mod.info must declare a poster')
} elseif (-not (Test-Path -LiteralPath (Join-Path $packageRoot $posterMatch.Groups[1].Value.Trim()) -PathType Leaf)) {
    Add-ValidationError("42/mod.info poster '$($posterMatch.Groups[1].Value.Trim())' does not exist in 42/")
}

$registeredAliases = @(Get-Captures $registry 'CharacterTrait\.register\("([^"]+)"\)' |
    ForEach-Object { $_.ToLowerInvariant() })
$definedAliases = @(Get-Captures $traitScript 'character_trait_definition\s+([^\s\{]+)' |
    ForEach-Object { $_.ToLowerInvariant() })
Test-IdParity 'legacy trait bridge' $registeredAliases $definedAliases
if ($registeredAliases.Count -ne 50) {
    Add-ValidationError("legacy trait bridge should register 50 aliases, found $($registeredAliases.Count)")
}
if ($traitScript -notmatch '(?m)^\s*module\s+ProfessionFramework\s*$') {
    Add-ValidationError('legacy trait script must use module ProfessionFramework')
}
Test-BraceBalance 'legacy trait script' $traitScript
if ($sharedApi -notmatch 'Lucky2\s*=\s*false' -or $sharedApi -notmatch 'Unlucky2\s*=\s*false') {
    Add-ValidationError('Build 42 API must explicitly reject removed Lucky2 and Unlucky2 aliases')
}

$forbiddenPatterns = @(
    'TraitFactory',
    'ProfessionFactory',
    'BaseGameCharacterDetails',
    'Events\.OnGameBoot'
)
$luaRoot = Join-Path $packageRoot 'media\lua'
if (Test-Path -LiteralPath $luaRoot -PathType Container) {
    foreach ($luaFile in Get-ChildItem -LiteralPath $luaRoot -Filter '*.lua' -File -Recurse) {
        $luaText = Get-Content -Raw -LiteralPath $luaFile.FullName
        foreach ($pattern in $forbiddenPatterns) {
            if ($luaText -match $pattern) {
                Add-ValidationError("$($luaFile.FullName.Substring($repoRoot.Length + 1)) still references retired Build 41 API '$pattern'")
            }
        }
    }
} else {
    Add-ValidationError('missing Build 42 Lua directory')
}

if ($serverApi -notmatch 'Events\.OnNewGame\.Add\(ProfessionFramework\.onNewGame\)') {
    Add-ValidationError('server API must register OnNewGame')
}
if ($serverApi -notmatch 'Events\.OnSpawnRegionsLoaded\.Add\(ProfessionFramework\.onSpawnRegionsLoaded\)') {
    Add-ValidationError('server API must register OnSpawnRegionsLoaded')
}
if ($clientApi -notmatch 'Events\.OnGameStart\.Add\(ProfessionFramework\.onGameStart\)') {
    Add-ValidationError('client API must register OnGameStart')
}
if ($clientApi -match 'OnNewGame') {
    Add-ValidationError('client API must not register OnNewGame')
}

$fixtureRoot = Join-Path $repoRoot 'examples\build42-consumer\42'
$fixtureManifest = Read-RequiredText (Join-Path $fixtureRoot 'mod.info') 'Build 42 consumer fixture manifest'
$fixtureRegistry = Read-RequiredText (Join-Path $fixtureRoot 'media\registries.lua') 'Build 42 consumer fixture registry'
$fixtureDefinitions = Read-RequiredText (Join-Path $fixtureRoot 'media\scripts\PFBuild42Consumer.txt') 'Build 42 consumer fixture definitions'
$fixtureBehavior = Read-RequiredText (Join-Path $fixtureRoot 'media\lua\shared\PFBuild42ConsumerBehavior.lua') 'Build 42 consumer fixture behavior'
$fixtureUi = Read-RequiredText (Join-Path $fixtureRoot 'media\lua\shared\Translate\EN\UI.json') 'Build 42 consumer fixture translations'

if ($fixtureManifest -notmatch '(?m)^require=ProfessionFramework\r?$') {
    Add-ValidationError('consumer fixture must require ProfessionFramework')
}
if ($fixtureManifest -notmatch '(?m)^versionMin=42\.20\r?$') {
    Add-ValidationError('consumer fixture must declare versionMin=42.20')
}
$fixtureTraits = @(Get-Captures $fixtureRegistry 'CharacterTrait\.register\("([^"]+)"\)' |
    ForEach-Object { $_.ToLowerInvariant() })
$fixtureProfessions = @(Get-Captures $fixtureRegistry 'CharacterProfession\.register\("([^"]+)"\)' |
    ForEach-Object { $_.ToLowerInvariant() })
$fixtureTraitDefinitions = @(Get-Captures $fixtureDefinitions 'character_trait_definition\s+([^\s\{]+)' |
    ForEach-Object { $_.ToLowerInvariant() })
$fixtureProfessionDefinitions = @(Get-Captures $fixtureDefinitions 'character_profession_definition\s+([^\s\{]+)' |
    ForEach-Object { $_.ToLowerInvariant() })
Test-IdParity 'consumer fixture traits' $fixtureTraits $fixtureTraitDefinitions
Test-IdParity 'consumer fixture professions' $fixtureProfessions $fixtureProfessionDefinitions
Test-BraceBalance 'consumer fixture definitions' $fixtureDefinitions
Test-TranslationKeys 'consumer fixture definitions' $fixtureDefinitions $fixtureUi
if ($fixtureBehavior -notmatch 'require\s+"ProfessionFramework/B42"') {
    Add-ValidationError('consumer fixture must require the Build 42 framework API')
}
if ($fixtureBehavior -notmatch 'attachTraitBehavior' -or $fixtureBehavior -notmatch 'attachProfessionBehavior') {
    Add-ValidationError('consumer fixture must demonstrate trait and profession behavior attachments')
}

if ($GameDir) {
    $gameDirFull = [System.IO.Path]::GetFullPath($GameDir)
    $gameTraitPath = Join-Path $gameDirFull 'media\scripts\generated\characters\character_traits.txt'
    $gameUiPath = Join-Path $gameDirFull 'media\lua\shared\Translate\EN\UI.json'
    $gameTraits = Read-RequiredText $gameTraitPath 'installed Build 42 trait definitions'
    $gameUi = Read-RequiredText $gameUiPath 'installed Build 42 UI translations'
    $vanillaTraits = @(Get-Captures $gameTraits 'character_trait_definition\s+([^\s\{]+)' |
        ForEach-Object { $_.ToLowerInvariant() })

    Test-VanillaTraitTargets 'legacy trait bridge' $traitScript $vanillaTraits
    Test-VanillaTraitTargets 'consumer fixture' $fixtureDefinitions $vanillaTraits
    Test-TranslationKeys 'legacy trait bridge' $traitScript $gameUi

    $hammer = Get-ChildItem -LiteralPath (Join-Path $gameDirFull 'media\scripts') -Filter '*.txt' -File -Recurse |
        Select-String -Pattern '(?m)^\s*item\s+Hammer\b' -List
    if (-not $hammer) {
        Add-ValidationError('consumer fixture references Base.Hammer, which is not present in the installed game scripts')
    }
}

if ($errors.Count -gt 0) {
    Write-Host 'Build 42 validation failed:' -ForegroundColor Red
    foreach ($validationError in $errors) {
        Write-Host " - $validationError" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Build 42 validation passed.' -ForegroundColor Green
