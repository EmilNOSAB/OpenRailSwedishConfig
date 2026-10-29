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
    Assert ([IO.File]::ReadAllText($result.Backup) -ceq $original) 'XML backup contains the original file'
    $afterFirstRun = [IO.File]::ReadAllText($xmlPath)
    $again = Registrera-Konfiguration $xmlPath ($configPath.ToLowerInvariant().Replace('\', '/') + '/') $examplePath
    Assert (-not $again.Changed) 'Repeated installation recognizes the same normalized path'
    Assert ([IO.File]::ReadAllText($xmlPath) -ceq $afterFirstRun) 'Repeated run does not rewrite XML or add duplicates'

    $collisionXml = Join-Path $testRoot 'collision\configuration.xml'
    Write-TestFile $collisionXml ($original.Replace('Other company', 'Swedish Standards Rail').Replace('_USTN_CONFIG_OTHER', '_USTN_CONFIG_SWEDISH_STANDARDS_RAIL'))
    $collisionNode = (Las-KonfigXml $collisionXml).DocumentElement.SelectSingleNode('ConfigurationModel').OuterXml
    $collision = Registrera-Konfiguration $collisionXml $configPath $examplePath
    Assert ($collision.Title -eq 'Swedish Standards Rail (2)') 'Name/variable collision creates a distinct entry'
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
