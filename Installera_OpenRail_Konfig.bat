@echo off
chcp 65001 >nul
setlocal EnableExtensions DisableDelayedExpansion
title Installera svenska OpenRail-standarder

rem ZIP bredvid BAT-filen anvands om den finns. Annars laddas URL ned.
rem GitHub-lanken fungerar nar konfigurationen har slagits ihop till main.
set "URL=https://github.com/EmilNOSAB/OpenRailSwedishConfig/archive/refs/heads/main.zip"
rem Valfri SHA256 for en fast version/release. Lamna tom for en rorlig main-ZIP.
set "SHA256="
set "SJALV=%~f0"
set "OPENRAIL_VERSION=%~1"

if /i "%~1"=="--help" (
    echo Installera_OpenRail_Konfig.bat [2026] [--no-pause]
    echo Installerar till C:\Swedish Standards Rail och lagger till i anvandarens configuration.xml.
    exit /b 0
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "try { $k = [IO.File]::ReadAllText($env:SJALV); & ([scriptblock]::Create($k.Substring($k.LastIndexOf('##' + 'POWERSHELL##')))); Installera-Konfiguration; exit 0 } catch { Write-Host ('[FEL] ' + $_.Exception.Message) -ForegroundColor Red; exit 1 }"
set "SLUTKOD=%errorlevel%"
echo.
if /i not "%~2"=="--no-pause" pause
exit /b %SLUTKOD%

##POWERSHELL##
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [Text.Encoding]::UTF8

function Normalisera-Sokvag([string]$Sokvag) {
    return [IO.Path]::GetFullPath($Sokvag).TrimEnd('\', '/').ToUpperInvariant()
}

function Las-KonfigXml([string]$Sokvag) {
    $doc = New-Object Xml.XmlDocument
    $doc.XmlResolver = $null
    if ([IO.File]::Exists($Sokvag)) {
        $settings = New-Object Xml.XmlReaderSettings
        $settings.DtdProcessing = [Xml.DtdProcessing]::Prohibit
        $settings.XmlResolver = $null
        $reader = [Xml.XmlReader]::Create($Sokvag, $settings)
        try { $doc.Load($reader) } finally { $reader.Dispose() }
        if ($doc.DocumentElement.LocalName -ne 'ArrayOfConfigurationModel' -or $doc.DocumentElement.NamespaceURI) {
            throw 'Okant XML-format. Befintlig configuration.xml har inte andrats.'
        }
    } else {
        [void]$doc.AppendChild($doc.CreateXmlDeclaration('1.0', 'utf-8', $null))
        [void]$doc.AppendChild($doc.CreateElement('ArrayOfConfigurationModel'))
        $doc.DocumentElement.SetAttribute('xmlns:xsd', 'http://www.w3.org/2001/XMLSchema')
        $doc.DocumentElement.SetAttribute('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance')
    }
    return ,$doc
}

function Ny-KonfigPost($Doc, [string]$Titel, [string]$Variabel, [string]$Sokvag, [bool]$Vald, [bool]$Redigerbar) {
    $post = $Doc.CreateElement('ConfigurationModel')
    $fields = [ordered]@{
        Title = $Titel
        Description = ''
        ConfigurationVariable = $Variabel
        Type = 'Local'
        IsActive = 'true'
        Path = [IO.Path]::GetFullPath($Sokvag).TrimEnd('\', '/') + '\'
        IsSelected = $Vald.ToString().ToLowerInvariant()
        IsEditable = $Redigerbar.ToString().ToLowerInvariant()
    }
    foreach ($name in $fields.Keys) {
        $child = $Doc.CreateElement($name)
        $child.InnerText = $fields[$name]
        [void]$post.AppendChild($child)
    }
    return ,$post
}

function Registrera-Konfiguration([string]$XmlFil, [string]$KonfigMapp, [string]$ExempelMapp) {
    $fanns = [IO.File]::Exists($XmlFil)
    $ursprung = if ($fanns) { [Convert]::ToBase64String([IO.File]::ReadAllBytes($XmlFil)) } else { $null }
    $doc = Las-KonfigXml $XmlFil
    $poster = @($doc.DocumentElement.SelectNodes('ConfigurationModel'))
    foreach ($post in $poster) {
        try { $samma = (Normalisera-Sokvag ([string]$post.Path)) -eq (Normalisera-Sokvag $KonfigMapp) }
        catch { $samma = $false }
        if ($samma) {
            return [pscustomobject]@{ Title = [string]$post.Title; Changed = $false; Backup = $null }
        }
    }

    # Vid forsta installationen behalls aven Bentleys levererade konfiguration.
    if (-not $fanns -and [IO.Directory]::Exists($ExempelMapp)) {
        [void]$doc.DocumentElement.AppendChild((Ny-KonfigPost $doc 'Examples Configuration' '_USTN_INSTALLED_CONFIGURATION' $ExempelMapp $true $false))
    }
    $poster = @($doc.DocumentElement.SelectNodes('ConfigurationModel'))
    $titel = 'Swedish Standards Rail'
    $variabel = '_USTN_CONFIG_SWEDISH_STANDARDS_RAIL'
    $index = 1
    while (@($poster | Where-Object { [string]$_.Title -eq $titel -or [string]$_.ConfigurationVariable -eq $variabel }).Count -gt 0) {
        $index++
        $titel = 'Swedish Standards Rail ({0})' -f $index
        $variabel = '_USTN_CONFIG_SWEDISH_STANDARDS_RAIL_{0}' -f $index
    }
    # Befintliga poster och deras IsSelected-varden lamnas ororda.
    [void]$doc.DocumentElement.AppendChild((Ny-KonfigPost $doc $titel $variabel $KonfigMapp ($poster.Count -eq 0) $true))
    $prefsMapp = [IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($XmlFil))
    [void][IO.Directory]::CreateDirectory($prefsMapp)
    $tempFil = Join-Path $prefsMapp ('.configuration-' + [guid]::NewGuid().ToString('N') + '.tmp')
    $backup = $null
    try {
        $settings = New-Object Xml.XmlWriterSettings
        $settings.Encoding = New-Object Text.UTF8Encoding($false)
        $settings.Indent = $true
        $writer = [Xml.XmlWriter]::Create($tempFil, $settings)
        try { $doc.Save($writer) } finally { $writer.Dispose() }
        [void](Las-KonfigXml $tempFil)
        if ($fanns) {
            if ([Convert]::ToBase64String([IO.File]::ReadAllBytes($XmlFil)) -ne $ursprung) {
                throw 'configuration.xml andrades av ett annat program. Ingen XML skrevs over; kor igen nar OpenRail ar stangt.'
            }
            $backup = $XmlFil + '.bak-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N')
            [IO.File]::Replace($tempFil, $XmlFil, $backup)
        } else {
            [IO.File]::Move($tempFil, $XmlFil)
        }
    } finally {
        if ([IO.File]::Exists($tempFil)) { [IO.File]::Delete($tempFil) }
    }
    return [pscustomobject]@{ Title = $titel; Changed = $true; Backup = $backup }
}

function Ladda-Ner([string]$Url, [string]$ZipFil, [string]$Sha256) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    for ($forsok = 1; $forsok -le 3; $forsok++) {
        $svar = $null; $inStream = $null; $utStream = $null
        try {
            $req = [Net.HttpWebRequest]::Create($Url)
            $req.Timeout = 30000
            $req.ReadWriteTimeout = 60000
            $svar = $req.GetResponse()
            $inStream = $svar.GetResponseStream()
            $utStream = [IO.File]::Create($ZipFil)
            $buf = New-Object byte[] 1048576
            $klart = 0L
            while (($n = $inStream.Read($buf, 0, $buf.Length)) -gt 0) {
                $utStream.Write($buf, 0, $n)
                $klart += $n
            }
            $utStream.Dispose(); $utStream = $null
            if ($svar.ContentLength -gt 0 -and $klart -ne $svar.ContentLength) { throw 'Nedladdningen ar inte komplett.' }
            if ($Sha256 -and (Get-FileHash -LiteralPath $ZipFil -Algorithm SHA256).Hash -ne $Sha256) { throw 'Fel SHA256-kontrollsumma.' }
            return
        } catch {
            if ($forsok -eq 3) { throw }
            Write-Host ("Forsok {0} misslyckades: {1}. Forsoker igen..." -f $forsok, $_.Exception.Message)
        } finally {
            if ($utStream) { $utStream.Dispose() }
            if ($inStream) { $inStream.Dispose() }
            if ($svar) { $svar.Dispose() }
        }
    }
}

function Packa-Upp([string]$ZipFil, [string]$Mal) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    Add-Type -AssemblyName System.IO.Compression
    $zip = [IO.Compression.ZipFile]::OpenRead($ZipFil)
    try {
        $namn = @($zip.Entries | ForEach-Object { $_.FullName.Replace('\', '/') })
        $rotter = @()
        foreach ($name in $namn) {
            if ($name -notmatch '(^|/)(_backup|_validation)/' -and $name -match '(^|/)WorkSpaceSetup\.cfg$') {
                $prefix = $name.Substring(0, $name.Length - 'WorkSpaceSetup.cfg'.Length)
                if (@($namn | Where-Object { $_.StartsWith($prefix + 'WorkSpaces/', [StringComparison]::OrdinalIgnoreCase) }).Count -gt 0 -and
                    @($namn | Where-Object { $_.StartsWith($prefix + 'Organization-Civil/', [StringComparison]::OrdinalIgnoreCase) }).Count -gt 0) {
                    $rotter += $prefix
                }
            }
        }
        if ($rotter.Count -ne 1) { throw 'ZIP-filen maste innehalla exakt en konfigurationsrot med WorkSpaceSetup.cfg, WorkSpaces och Organization-Civil.' }
        $malRot = [IO.Path]::GetFullPath($Mal).TrimEnd('\', '/') + '\'
        [void][IO.Directory]::CreateDirectory($malRot)
        $antal = 0
        foreach ($post in $zip.Entries) {
            $name = $post.FullName.Replace('\', '/')
            if (-not $name.StartsWith($rotter[0], [StringComparison]::OrdinalIgnoreCase)) { continue }
            $relativ = $name.Substring($rotter[0].Length)
            # Anvandarens prefs/XML, installationsinstallningar och lokala rapporter ingar aldrig.
            if ($relativ -match '(^|/)(prefs|_backup|_validation|_installer-backups)/' -or
                $relativ -match '(^|/)(configuration\.xml|ConfigurationSetup\.cfg)$') { continue }
            $dest = [IO.Path]::GetFullPath([IO.Path]::Combine($malRot, $relativ.Replace('/', '\')))
            if ($dest.TrimEnd('\') -eq $malRot.TrimEnd('\') -and $name.EndsWith('/')) { continue }
            if (-not $dest.StartsWith($malRot, [StringComparison]::OrdinalIgnoreCase)) { throw ('Otillaten ZIP-sokvag: ' + $name) }
            # Endast standardmappar installeras; BAT, tester och andra repofiler hoppas over.
            if ($relativ -notmatch '^(WorkSpaceSetup\.cfg$|Organization/|Organization-Civil/|WorkSpaces/)') { continue }
            if (($post.ExternalAttributes -shr 16 -band 0xF000) -eq 0xA000) { throw 'Symboliska lankar i ZIP stods inte.' }
            if ($name.EndsWith('/')) { [void][IO.Directory]::CreateDirectory($dest); continue }
            [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($dest))
            [IO.Compression.ZipFileExtensions]::ExtractToFile($post, $dest, $false)
            $antal++
        }
        if ($antal -eq 0) { throw 'Inga konfigurationsfiler hittades i ZIP-filen.' }
        return $antal
    } finally { $zip.Dispose() }
}

function Installera-Filer([string]$Kalla, [string]$Mal) {
    $kallRot = [IO.Path]::GetFullPath($Kalla).TrimEnd('\', '/') + '\'
    $malRot = [IO.Path]::GetFullPath($Mal).TrimEnd('\', '/') + '\'
    if ($malRot.StartsWith($kallRot, [StringComparison]::OrdinalIgnoreCase) -or $kallRot.StartsWith($malRot, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Kallmapp och malmapp maste vara separata.'
    }
    [void][IO.Directory]::CreateDirectory($malRot)
    $backupRot = Join-Path $malRot ('_installer-backups\' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N'))
    $journal = New-Object 'Collections.Generic.List[object]'
    try {
        foreach ($fil in Get-ChildItem -LiteralPath $kallRot -Recurse -File -Force | Sort-Object FullName) {
            if (($fil.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw 'Lankade kallfiler stods inte.' }
            $relativ = $fil.FullName.Substring($kallRot.Length)
            $dest = [IO.Path]::GetFullPath((Join-Path $malRot $relativ))
            if (-not $dest.StartsWith($malRot, [StringComparison]::OrdinalIgnoreCase)) { throw 'Filen ligger utanfor malmappen.' }
            # Folj aldrig en befintlig junction/symbolisk lank ut fran malmappen.
            $kontroll = $dest
            while ($kontroll -and $kontroll.Length -ge $malRot.TrimEnd('\').Length) {
                if (Test-Path -LiteralPath $kontroll) {
                    if (((Get-Item -LiteralPath $kontroll -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw ('Malet innehaller en lank: ' + $kontroll) }
                }
                $kontroll = [IO.Path]::GetDirectoryName($kontroll)
            }
            $backup = $null
            if ([IO.File]::Exists($dest)) {
                if ($fil.Length -eq (Get-Item -LiteralPath $dest).Length -and
                    (Get-FileHash -LiteralPath $fil.FullName -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash) { continue }
                $backup = Join-Path $backupRot $relativ
                [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($backup))
                [IO.File]::Copy($dest, $backup, $false)
            }
            [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($dest))
            $journal.Add([pscustomobject]@{ Destination = $dest; Backup = $backup })
            [IO.File]::Copy($fil.FullName, $dest, $true)
        }
    } catch {
        $fel = $_
        for ($i = $journal.Count - 1; $i -ge 0; $i--) {
            $rad = $journal[$i]
            if ($rad.Backup) { [IO.File]::Copy($rad.Backup, $rad.Destination, $true) }
            elseif ([IO.File]::Exists($rad.Destination)) { [IO.File]::Delete($rad.Destination) }
        }
        throw $fel
    }
    return [pscustomobject]@{ Files = $journal.Count; Backup = $(if ([IO.Directory]::Exists($backupRot)) { $backupRot } else { $null }) }
}

function Kan-Skriva([string]$Mapp) {
    $probeMapp = $Mapp
    while (-not [IO.Directory]::Exists($probeMapp)) { $probeMapp = [IO.Path]::GetDirectoryName($probeMapp) }
    $testFil = Join-Path $probeMapp ('.openrail-write-' + [guid]::NewGuid().ToString('N') + '.tmp')
    try { [IO.File]::WriteAllText($testFil, 'test'); return $true }
    catch [UnauthorizedAccessException] { return $false }
    catch [Security.SecurityException] { return $false }
    finally { if ([IO.File]::Exists($testFil)) { [IO.File]::Delete($testFil) } }
}

function Installera-MedBehorighet([string]$Kalla, [string]$Mal, [string]$SkriptFil, [string]$ResultatFil) {
    if (Kan-Skriva $Mal) { return Installera-Filer $Kalla $Mal }
    Write-Host 'Skrivning till C:\ kraver administrator. Endast filkopieringen hojs; XML uppdateras av din vanliga anvandare.'
    $scriptLiteral = "'" + $SkriptFil.Replace("'", "''") + "'"
    $sourceLiteral = "'" + $Kalla.Replace("'", "''") + "'"
    $destLiteral = "'" + $Mal.Replace("'", "''") + "'"
    $resultLiteral = "'" + $ResultatFil.Replace("'", "''") + "'"
    $command = @"
try {
    `$k = [IO.File]::ReadAllText($scriptLiteral)
    & ([scriptblock]::Create(`$k.Substring(`$k.LastIndexOf('##' + 'POWERSHELL##'))))
    Installera-Filer $sourceLiteral $destLiteral | ConvertTo-Json | Set-Content -LiteralPath $resultLiteral -Encoding UTF8
    exit 0
} catch {
    @{ Error = `$_.Exception.Message } | ConvertTo-Json | Set-Content -LiteralPath $resultLiteral -Encoding UTF8
    exit 1
}
"@
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
    $process = Start-Process -FilePath (Join-Path $PSHOME 'powershell.exe') -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-EncodedCommand', $encoded) -Verb RunAs -WindowStyle Hidden -Wait -PassThru
    if (-not [IO.File]::Exists($ResultatFil)) { throw 'Filinstallationen avbrots; ingen XML har andrats.' }
    $result = Get-Content -LiteralPath $ResultatFil -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($process.ExitCode -ne 0 -or $result.Error) { throw ('Filinstallationen misslyckades: ' + $result.Error) }
    return $result
}

function Installera-Konfiguration {
    Write-Host 'Installation av svenska OpenRail-standarder'
    $version = $env:OPENRAIL_VERSION
    if (-not $version) {
        $version = Read-Host 'OpenRail-version, fyra siffror [2026]'
        if (-not $version) { $version = '2026' }
    }
    if ($version -notmatch '^20\d{2}$' -or [int]$version -lt 2023) { throw 'Ange en version fran 2023 eller senare, till exempel 2026.' }
    if (Get-Process -Name OpenRailDesigner -ErrorAction SilentlyContinue) { throw 'Stang OpenRail Designer innan installationen kors. Inga filer har andrats.' }
    $prefsVersion = '{0}.0.0' -f ([int]$version - 2000)
    $localData = [Environment]::GetFolderPath('LocalApplicationData')
    $xmlFil = Join-Path $localData ('Bentley\OpenRailDesigner\' + $prefsVersion + '\prefs\configuration.xml')
    $exempelMapp = Join-Path $env:ProgramData ('Bentley\OpenRail Designer ' + $version + '.00\Configuration')
    $mal = 'C:\Swedish Standards Rail'
    # Kontrollera XML innan nagra konfigurationsfiler andras.
    [void](Las-KonfigXml $xmlFil)
    $tempRot = Join-Path ([IO.Path]::GetTempPath()) ('OpenRail-Konfig-' + [guid]::NewGuid().ToString('N'))
    [void][IO.Directory]::CreateDirectory($tempRot)
    try {
        $zipFil = Join-Path ([IO.Path]::GetDirectoryName($env:SJALV)) 'Swedish Standards Rail.zip'
        if ([IO.File]::Exists($zipFil)) {
            Write-Host ('Anvander ZIP bredvid BAT: ' + $zipFil)
            if ($env:SHA256 -and (Get-FileHash -LiteralPath $zipFil -Algorithm SHA256).Hash -ne $env:SHA256) { throw 'Fel SHA256-kontrollsumma for lokal ZIP.' }
        } else {
            if (-not $env:URL) { throw 'Ingen lokal ZIP eller nedladdnings-URL har angetts.' }
            $zipFil = Join-Path $tempRot 'konfiguration.zip'
            Write-Host ('Laddar ner: ' + $env:URL)
            Ladda-Ner $env:URL $zipFil $env:SHA256
        }
        $kalla = Join-Path $tempRot 'extracted'
        $antal = Packa-Upp $zipFil $kalla
        Write-Host ("{0} filer kontrollerade. Installerar till {1}" -f $antal, $mal)
        if (Get-Process -Name OpenRailDesigner -ErrorAction SilentlyContinue) { throw 'OpenRail startades under nedladdningen. Stang programmet och kor igen.' }
        $installation = Installera-MedBehorighet $kalla $mal $env:SJALV (Join-Path $tempRot 'install-result.json')
        if ($installation.Backup) { Write-Host ('Sakerhetskopia av ersatta filer: ' + $installation.Backup) }
        if (Get-Process -Name OpenRailDesigner -ErrorAction SilentlyContinue) { throw 'Filerna ar installerade. Stang OpenRail och kor igen for att registrera konfigurationen.' }
        $registrering = Registrera-Konfiguration $xmlFil $mal $exempelMapp
        Write-Host ('KLART! Konfiguration: ' + $registrering.Title)
        Write-Host ('XML: ' + $xmlFil)
        if ($registrering.Backup) { Write-Host ('XML-sakerhetskopia: ' + $registrering.Backup) }
        if (-not $registrering.Changed) { Write-Host 'Konfigurationen fanns redan. Ingen extra XML-post skapades.' }
        Write-Host 'Befintliga konfigurationer och valt alternativ har bevarats.'
        Write-Host ('Starta OpenRail och valj "' + $registrering.Title + '" i konfigurationslistan.')
    } finally {
        # Radera bara den temporara mapp som skapades av denna korning.
        $tempBas = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\') + '\'
        $resolvedTemp = [IO.Path]::GetFullPath($tempRot)
        if (-not $resolvedTemp.StartsWith($tempBas, [StringComparison]::OrdinalIgnoreCase) -or [IO.Path]::GetFileName($resolvedTemp) -notlike 'OpenRail-Konfig-*') { throw 'Ogiltig tempmapp; automatisk stadning avbrots.' }
        if ([IO.Directory]::Exists($resolvedTemp)) { Remove-Item -LiteralPath $resolvedTemp -Recurse -Force }
    }
}
