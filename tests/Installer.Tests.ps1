param([string]$Installer = (Join-Path $PSScriptRoot '..\Installera_OpenRail_Konfig.bat'))
$ErrorActionPreference = 'Stop'
$source = [IO.File]::ReadAllText((Resolve-Path -LiteralPath $Installer))
$code = $source.Substring($source.LastIndexOf('##' + 'POWERSHELL##'))
$tokens = $null; $parseErrors = $null
[void][Management.Automation.Language.Parser]::ParseInput($code, [ref]$tokens, [ref]$parseErrors)
if ($parseErrors.Count) { throw ($parseErrors | Out-String) }
. ([scriptblock]::Create($code))
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('OpenRail-InstallerTests-' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($testRoot)
$script:checks = 0
function Assert($Condition, [string]$Message) {
    if (-not $Condition) { throw ('FAIL: ' + $Message) }
    $script:checks++
}
function Assert-Throws([scriptblock]$Action, [string]$Message) {
    $threw = $false
    try { & $Action | Out-Null } catch { $threw = $true }
    Assert $threw $Message
}
function Write-TestFile([string]$Path, [string]$Content) {
    [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($Path))
    [IO.File]::WriteAllText($Path, $Content, (New-Object Text.UTF8Encoding($false)))
}
function New-TestZip([string]$Path, $Entries) {
    $zip = [IO.Compression.ZipFile]::Open($Path, [IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($name in $Entries.Keys) {
            $entry = $zip.CreateEntry($name)
            $writer = New-Object IO.StreamWriter($entry.Open())
            try { $writer.Write([string]$Entries[$name]) } finally { $writer.Dispose() }
        }
    } finally { $zip.Dispose() }
}
try {
    # Exercise the BAT entry point in a fresh process. An invalid year stops
    # before downloads, configuration copies, or changes to the user's prefs.
    Push-Location -LiteralPath (Split-Path -Parent (Resolve-Path -LiteralPath $Installer).Path)
    try {
        $launcherOutput = & $env:ComSpec /d /c ('"' + (Split-Path -Leaf $Installer) + '" invalid --no-pause')
        $launcherExit = $LASTEXITCODE
    } finally { Pop-Location }
    Assert ($launcherExit -eq 1) 'BAT returns a failure exit code for an invalid year'
    Assert (($launcherOutput -join "`n") -match 'Ange en version från 2023') 'BAT loads the entry function and reaches version validation'

    $configPath = Join-Path $testRoot 'installed\Swedish Standards Rail'
    $examplePath = Join-Path $testRoot 'BentleyExamples'
    [void][IO.Directory]::CreateDirectory($examplePath)
    $xmlPath = Join-Path $testRoot 'prefs\configuration.xml'
    $original = @'
<?xml version="1.0" encoding="utf-8"?>
<ArrayOfConfigurationModel marker="keep-root-attribute">
  <!-- Keep this comment and all existing configuration fields. -->
  <ConfigurationModel>
    <Title>Other company</Title><Description>Keep &amp; preserve</Description>
    <ConfigurationVariable>_USTN_CONFIG_OTHER</ConfigurationVariable><Type>Network</Type>
    <IsActive>false</IsActive><Path>C:\OtherConfig\</Path><IsSelected>true</IsSelected><IsEditable>false</IsEditable>
    <FutureField setting="keep">Original value</FutureField>
  </ConfigurationModel>
</ArrayOfConfigurationModel>
'@
    Write-TestFile $xmlPath $original
    $beforeNode = (Las-KonfigXml $xmlPath).DocumentElement.SelectSingleNode('ConfigurationModel').OuterXml
    $result = Registrera-Konfiguration $xmlPath $configPath $examplePath
    $doc = Las-KonfigXml $xmlPath
    Assert ($result.Changed -eq $true) 'New configuration is added'
    Assert ($doc.DocumentElement.SelectNodes('ConfigurationModel').Count -eq 2) 'Other configuration remains'
    Assert ($doc.DocumentElement.SelectSingleNode('ConfigurationModel').OuterXml -ceq $beforeNode) 'Existing entry including selection and unknown fields is unchanged'
    Assert ($doc.DocumentElement.GetAttribute('marker') -eq 'keep-root-attribute') 'Root attributes are preserved'
    Assert ($doc.SelectNodes('//comment()').Count -eq 1) 'Comments are preserved'
    Assert ($doc.DocumentElement.LastChild.IsSelected -eq 'false') 'New entry does not change existing selection'
    Assert ($doc.DocumentElement.LastChild.Title -eq 'BJP26') 'Configuration uses the BJP26 display name'
    Assert ($doc.DocumentElement.LastChild.ConfigurationVariable -eq '_USTN_CONFIG_SWEDISH_STANDARDS_RAIL') 'Configuration variable is retained'
    Assert ([IO.File]::ReadAllText($result.Backup) -ceq $original) 'XML backup contains the original file'
    $afterFirstRun = [IO.File]::ReadAllText($xmlPath)
    $again = Registrera-Konfiguration $xmlPath ($configPath.ToLowerInvariant().Replace('\', '/') + '/') $examplePath
    Assert (-not $again.Changed) 'Repeated installation recognizes the same normalized path'
    Assert ([IO.File]::ReadAllText($xmlPath) -ceq $afterFirstRun) 'Repeated run does not rewrite XML or add duplicates'

    $legacyXml = Join-Path $testRoot 'legacy\configuration.xml'
    $legacyContent = $afterFirstRun.Replace('<Title>BJP26</Title>', '<Title>Swedish Standards Rail</Title>')
    Write-TestFile $legacyXml $legacyContent
    $renamed = Registrera-Konfiguration $legacyXml $configPath $examplePath
    $renamedDoc = Las-KonfigXml $legacyXml
    Assert ($renamed.Changed -and $renamed.Title -eq 'BJP26') 'Previous default display name is migrated to BJP26'
    Assert ($renamedDoc.DocumentElement.SelectNodes('ConfigurationModel').Count -eq 2) 'Renaming does not add a duplicate'
    Assert ($renamedDoc.DocumentElement.LastChild.OuterXml -ceq $doc.DocumentElement.LastChild.OuterXml) 'Renaming preserves every other field of the existing configuration'
    Assert ([IO.File]::ReadAllText($renamed.Backup) -ceq $legacyContent) 'Renaming backs up the original XML'
    Assert (-not (Registrera-Konfiguration $legacyXml $configPath $examplePath).Changed) 'Repeated install after renaming does not rewrite XML'

    $collisionXml = Join-Path $testRoot 'collision\configuration.xml'
    Write-TestFile $collisionXml ($original.Replace('Other company', 'BJP26').Replace('_USTN_CONFIG_OTHER', '_USTN_CONFIG_SWEDISH_STANDARDS_RAIL'))
    $collisionNode = (Las-KonfigXml $collisionXml).DocumentElement.SelectSingleNode('ConfigurationModel').OuterXml
    $collision = Registrera-Konfiguration $collisionXml $configPath $examplePath
    Assert ($collision.Title -eq 'BJP26 (2)') 'Name/variable collision creates a distinct entry'
    Assert ((Las-KonfigXml $collisionXml).DocumentElement.FirstChild.NextSibling.OuterXml -ceq $collisionNode) 'Collision does not modify the other configuration'

    $newXml = Join-Path $testRoot 'new-profile\configuration.xml'
    [void](Registrera-Konfiguration $newXml $configPath $examplePath)
    $newDoc = Las-KonfigXml $newXml
    Assert ($newDoc.DocumentElement.SelectNodes('ConfigurationModel').Count -eq 2) 'New user gets Bentley examples plus custom config'
    Assert ($newDoc.DocumentElement.FirstChild.ConfigurationVariable -eq '_USTN_INSTALLED_CONFIGURATION') 'Bentley example entry uses the correct variable'
    Assert ($newDoc.DocumentElement.FirstChild.IsSelected -eq 'true') 'Bentley examples remain selected for a new user'
    $emptyXml = Join-Path $testRoot 'no-examples\configuration.xml'
    [void](Registrera-Konfiguration $emptyXml $configPath (Join-Path $testRoot 'missing-examples'))
    Assert ((Las-KonfigXml $emptyXml).DocumentElement.FirstChild.IsSelected -eq 'true') 'A lone first configuration is selectable by default'

    foreach ($invalid in @('<not-valid', '<UnknownRoot/>', '<!DOCTYPE x [<!ENTITY e SYSTEM "file:///C:/secret">]><ArrayOfConfigurationModel>&e;</ArrayOfConfigurationModel>')) {
        $badXml = Join-Path $testRoot ('invalid-' + [guid]::NewGuid().ToString('N') + '.xml')
        Write-TestFile $badXml $invalid
        Assert-Throws { Registrera-Konfiguration $badXml $configPath $examplePath } 'Invalid or unsupported XML is rejected'
        Assert ([IO.File]::ReadAllText($badXml) -ceq $invalid) 'Rejected XML is never replaced'
    }

    $entries = [ordered]@{
        'repo-main/WorkSpaceSetup.cfg' = '# setup'
        'repo-main/WorkSpaces/Swedish Standards.cfg' = '# workspace'
        'repo-main/Organization-Civil/Swedish Standards.cfg' = '# organization'
        'repo-main/Organization/standards.cfg' = '# standards'
        'repo-main/configuration.xml' = '<must-not-install/>'
        'repo-main/prefs/configuration.xml' = '<must-not-install/>'
        'repo-main/Organization/configuration.xml' = '<must-not-install/>'
        'repo-main/ConfigurationSetup.cfg' = '# must not install'
        'repo-main/_backup/old.cfg' = '# must not install'
        'repo-main/_validation/report.txt' = 'must not install'
        'repo-main/Installera_OpenRail_Konfig.bat' = 'must not execute or install'
    }
    $zipPath = Join-Path $testRoot 'wrapped.zip'
    New-TestZip $zipPath $entries
    $staging = Join-Path $testRoot 'extracted'
    Assert ((Packa-Upp $zipPath $staging) -eq 4) 'GitHub archive wrapper is detected and only configuration content is extracted'
    Assert ((Get-ChildItem -LiteralPath $staging -Recurse -File | Where-Object Name -eq 'configuration.xml').Count -eq 0) 'ZIP cannot supply a preferences XML'
    Assert (-not (Test-Path -LiteralPath (Join-Path $staging 'ConfigurationSetup.cfg'))) 'Installed ConfigurationSetup.cfg is never supplied by the ZIP'
    $flatEntries = [ordered]@{}
    foreach ($key in $entries.Keys) { $flatEntries[$key.Substring('repo-main/'.Length)] = $entries[$key] }
    $flatZip = Join-Path $testRoot 'flat.zip'
    New-TestZip $flatZip $flatEntries
    Assert ((Packa-Upp $flatZip (Join-Path $testRoot 'flat-extracted')) -eq 4) 'Flat ZIPs are also supported'
    $entries['repo-main/../escape.txt'] = 'must not escape'
    $unsafeZip = Join-Path $testRoot 'unsafe.zip'
    New-TestZip $unsafeZip $entries
    Assert-Throws { Packa-Upp $unsafeZip (Join-Path $testRoot 'unsafe-extracted') } 'Path traversal is rejected'
    Assert (-not (Test-Path -LiteralPath (Join-Path $testRoot 'escape.txt'))) 'ZIP never writes outside its extraction root'

    $installDest = Join-Path $testRoot 'destination'
    Write-TestFile (Join-Path $installDest 'Organization\standards.cfg') '# local previous version'
    Write-TestFile (Join-Path $installDest 'WorkSpaces\MyProject\drawing.dgn') 'user project data'
    $installed = Installera-Filer $staging $installDest
    Assert ($installed.Files -eq 4) 'Configuration files install successfully'
    Assert ([IO.File]::ReadAllText((Join-Path $installed.Backup 'Organization\standards.cfg')) -eq '# local previous version') 'Replaced files are backed up'
    Assert ([IO.File]::ReadAllText((Join-Path $installDest 'WorkSpaces\MyProject\drawing.dgn')) -eq 'user project data') 'Additional project files are preserved'
    Assert ((Installera-Filer $staging $installDest).Files -eq 0) 'Unchanged files are not rewritten on repeat runs'

    # Run the administrator helper in a real child PowerShell process, replacing
    # only the permission check and UAC launch so all writes stay in testRoot.
    $savedWriteCheck = ${function:Kan-Skriva}
    try {
        function Kan-Skriva { return $false }
        function Start-Process {
            param($FilePath, $ArgumentList, $Verb, $WindowStyle, [switch]$Wait, [switch]$PassThru)
            Microsoft.PowerShell.Management\Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -WindowStyle Hidden -Wait -PassThru
        }
        $helperDest = Join-Path $testRoot 'helper-destination'
        $helperResult = Installera-MedBehorighet $staging $helperDest (Resolve-Path -LiteralPath $Installer).Path (Join-Path $testRoot 'helper-result.json')
        Assert ($helperResult.Files -eq 4) 'Administrator helper loads functions in its child process and copies files'
        Assert ([IO.File]::ReadAllText((Join-Path $helperDest 'WorkSpaceSetup.cfg')) -eq '# setup') 'Administrator helper installs the expected content'
    } finally {
        Set-Item -LiteralPath function:Kan-Skriva -Value $savedWriteCheck
        Remove-Item -LiteralPath function:Start-Process
    }

    $lvaSource = Join-Path $testRoot 'lva-source'
    $lvaDest = Join-Path $testRoot 'lva-destination'
    Write-TestFile (Join-Path $lvaSource 'Organization-Civil\LVA.cfg') '# local LVA'
    $stockCell = 'Organization-Civil\Swedish Standards\Cell\LV Assets 3D.cel'
    $stockItemTypes = 'Organization-Civil\Swedish Standards\Dgnlib\Feature Definitions\Rail\LV Assets Item Types.dgnLib'
    Write-TestFile (Join-Path $lvaDest $stockCell) 'previous stock cells'
    Write-TestFile (Join-Path $lvaDest $stockItemTypes) 'previous stock item types'
    Write-TestFile (Join-Path $lvaDest 'WorkSpaces\MyProject\drawing.dgn') 'keep project data'
    [void](Installera-Filer $lvaSource $lvaDest)
    Assert (Test-Path -LiteralPath (Join-Path $lvaDest $stockCell)) 'Incomplete replacement never retires stock LVA'
    foreach ($code in @('BANA', 'BELYSNING', 'KANALISATION', 'KONTAKTLEDNING', 'LSP', 'TELE')) {
        Write-TestFile (Join-Path $lvaSource ('Organization-Civil\LVA\Dgnlib\NCAD-OR-STANDARDS-{0}.dgnlib' -f $code)) 'new standards'
        Write-TestFile (Join-Path $lvaSource ('Organization-Civil\LVA\Cell\2D\NCAD-OR-CELL2D-{0}.cel' -f $code)) 'new 2D cells'
        Write-TestFile (Join-Path $lvaSource ('Organization-Civil\LVA\Cell\3D\NCAD-OR-CELL3D-{0}.cel' -f $code)) 'new 3D cells'
    }
    $lvaInstall = Installera-Filer $lvaSource $lvaDest
    Assert (-not (Test-Path -LiteralPath (Join-Path $lvaDest $stockCell))) 'Complete LVA replacement removes stock cells'
    Assert (-not (Test-Path -LiteralPath (Join-Path $lvaDest $stockItemTypes))) 'Complete LVA replacement removes stock Item Types'
    Assert ([IO.File]::ReadAllText((Join-Path $lvaInstall.Backup $stockCell)) -eq 'previous stock cells') 'Retired stock library is backed up'
    Assert ([IO.File]::ReadAllText((Join-Path $lvaDest 'WorkSpaces\MyProject\drawing.dgn')) -eq 'keep project data') 'LVA migration preserves project files'
    Assert ((Installera-Filer $lvaSource $lvaDest).Files -eq 0) 'Repeated LVA migration makes no further changes'

    # A failure after one retirement restores both the retired file and copies.
    $lvaRollback = Join-Path $testRoot 'lva-rollback'
    $lockedCell = 'Organization-Civil\Swedish Standards\Cell\LV Assets Annotations.cel'
    Write-TestFile (Join-Path $lvaRollback $stockCell) 'restore these cells'
    Write-TestFile (Join-Path $lvaRollback $lockedCell) 'locked library'
    $lock = [IO.File]::Open((Join-Path $lvaRollback $lockedCell), [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
    try {
        Assert-Throws { Installera-Filer $lvaSource $lvaRollback } 'Locked stock library fails the migration'
    } finally { $lock.Dispose() }
    Assert ([IO.File]::ReadAllText((Join-Path $lvaRollback $stockCell)) -eq 'restore these cells') 'Migration rollback restores an already retired stock library'
    Assert (-not (Test-Path -LiteralPath (Join-Path $lvaRollback 'Organization-Civil\LVA.cfg'))) 'Migration rollback removes newly copied files'

    $rollbackSource = Join-Path $testRoot 'rollback-source'
    $rollbackDest = Join-Path $testRoot 'rollback-destination'
    Write-TestFile (Join-Path $rollbackSource 'a-new.cfg') 'new file'
    Write-TestFile (Join-Path $rollbackSource 'b-replace.cfg') 'new contents'
    Write-TestFile (Join-Path $rollbackSource 'z-conflict.cfg') 'conflict'
    Write-TestFile (Join-Path $rollbackDest 'b-replace.cfg') 'original contents'
    [void][IO.Directory]::CreateDirectory((Join-Path $rollbackDest 'z-conflict.cfg'))
    Assert-Throws { Installera-Filer $rollbackSource $rollbackDest } 'Copy failure triggers rollback'
    Assert ([IO.File]::ReadAllText((Join-Path $rollbackDest 'b-replace.cfg')) -eq 'original contents') 'Rollback restores overwritten files'
    Assert (-not (Test-Path -LiteralPath (Join-Path $rollbackDest 'a-new.cfg'))) 'Rollback removes newly installed files'
    Write-Host ("PASS: {0} installer checks" -f $script:checks)
} finally {
    $allowedRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\') + '\'
    $resolvedRoot = [IO.Path]::GetFullPath($testRoot)
    if (-not $resolvedRoot.StartsWith($allowedRoot, [StringComparison]::OrdinalIgnoreCase) -or [IO.Path]::GetFileName($resolvedRoot) -notlike 'OpenRail-InstallerTests-*') { throw 'Unsafe test cleanup path.' }
    Remove-Item -LiteralPath $resolvedRoot -Recurse -Force
}
