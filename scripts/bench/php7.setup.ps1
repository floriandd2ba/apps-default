$phpDir = App-Dir "Bench.PHP7"
$activeExtensions = Get-AppConfigListValue "Bench.PHP7" "Extensions"
$iniLines = Get-Content "$phpDir\php.ini-development"

$sectionP = [regex]"^\[(?<section>\w+)\]$"
$dirP = [regex]"^[\s;]*extension_dir\s*=\s*`"ext`"\s*$"
$extensionP = [regex]"^[\s;]*extension\s*=\s*(?<extlib>.*?)\s*$"

$section = ""
for ($i = 0; $i -lt $iniLines.Count; $i++)
{
    $line = $iniLines[$i]
    $sectionM = $sectionP.Match($line)
    if ($sectionM.Success)
    {
        $section = $sectionM.Groups["section"].Value
        continue
    }
    if ($section -ne "PHP")
    {
        continue
    }
    $dirM = $dirP.Match($line)
    if ($dirM.Success)
    {
        Write-Host "Setting path for PHP extension directory"
        $iniLines[$i] = "extension_dir = `"ext`""
        continue
    }
    $extensionM = $extensionP.Match($line)
    if ($extensionM.Success)
    {
        $extlib = $extensionM.Groups["extlib"].Value
        foreach ($ext in $activeExtensions)
        {
            if ($extlib -eq $ext -or $extlib -eq "${ext}.dll")
            {
                "Activating dynamic PHP extension $ext"
                $iniLines[$i] = "extension=$extlib"
            }
        }
    }
}

$iniLines | Out-File "$phpDir\php.ini" -Encoding Default
